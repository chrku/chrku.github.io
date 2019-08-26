
// Call entry point
window.onload = main;

//
// Globals for graphics & WebGL
//

// Vertex shader; very simple, simply do standard MVP matrix multiplication
const vertexShaderSource = `
  attribute vec4 aVertexPosition;
  
  uniform mat4 uModelMatrix;
  uniform mat4 uViewMatrix;
  uniform mat4 uProjectionMatrix;
  
  void main() {
    gl_Position = uProjectionMatrix * uViewMatrix * uModelMatrix * aVertexPosition;
  }
`;

let fragmentShaderSource = null;

// This documents the current fragment shader source
// Since this is editable by users, it needs a flag to check if it
// is still up to date
let shaderSourceChanged = false;

// Records the current valid shader program
let currentShaderProgram = null;

// Coordinates for a square plane
const squareCoords = [
  -1.0, 1.0,
  1.0, 1.0,
  -1.0, -1.0,
  1.0, -1.0
];

// Global variables for mouse position
let mousePos = {
  x: 0,
  y: 0
};

let shaderSources = [];

//
// Globals for UI
//

// Global variables for accessing the canvas and editor state
let editor = null;
let canvas = null;

//
// Functions for graphics & WebGL
//

// Recompile shader
function recompileShader() {
  shaderSourceChanged = true;
}

function setNewShader(gl) {
  // Try recompiling new shaders
  const currentShaderSource = editor.getValue();
  const newProgram = makeNewShaderProgram(gl, vertexShaderSource, currentShaderSource);
  if (newProgram) {
    currentShaderProgram = newProgram;
    fragmentShaderSource = currentShaderSource;
  }
  shaderSourceChanged = false;
}

function drawScene(time, gl, shaderProgram, VBO, width, height, mouseX, mouseY) {
  // Clear before drawing
  gl.clearColor(0.0, 0.0, 0.0, 1);
  gl.clear(gl.COLOR_BUFFER_BIT);

  // Get orthographic projection matrix
  const projection = mat4.create();
  mat4.ortho(projection, -1, 1, -1, 1, -1, 1);

  // Create model matrix (identity)
  const model = mat4.create();

  // Create view matrix (also identity)
  const view = mat4.create();

  // Set up vertex attribute pointer and bind VBO
  // This doesn't have VAOs for some reason...
  gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
  gl.vertexAttribPointer(
    0,
    2,
    gl.FLOAT,
    false,
    0,
    0
  );
  gl.enableVertexAttribArray(0);
  // Use shader program
  gl.useProgram(shaderProgram);

  // Set uniforms for the rectangle
  gl.uniformMatrix4fv(gl.getUniformLocation(shaderProgram, 'uProjectionMatrix'), false, projection);
  gl.uniformMatrix4fv(gl.getUniformLocation(shaderProgram, 'uViewMatrix'), false, view);
  gl.uniformMatrix4fv(gl.getUniformLocation(shaderProgram, 'uModelMatrix'), false, model);

  // Set other uniforms
  // Mouse
  gl.uniform2f(gl.getUniformLocation(shaderProgram, 'u_mouse'), mouseX, height - mouseY);
  // Resolution
  gl.uniform2f(gl.getUniformLocation(shaderProgram, 'u_resolution'), width, height);
  // Time
  gl.uniform1f(gl.getUniformLocation(shaderProgram, 'u_time'), time);

  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
}

// This is called each frame using requestAnimationFrame()
function render(time) {
  // Convert time to seconds
  time *= 0.001;
  // The GL context is bound to the function
  const gl = this.glContext;
  const VBO = this.VBO;
  const canvasWidth = canvas.width;
  const canvasHeight = canvas.height;
  updateUniformDisplay(canvasWidth, canvasHeight, mousePos, time);

  // Check if the shader source changed since last render
  if (shaderSourceChanged) {
    setNewShader(gl);
  }

  drawScene(time, gl, currentShaderProgram, VBO, canvasWidth, canvasHeight, mousePos.x, mousePos.y);

  requestAnimationFrame(render.bind(this));
}

function loadShader(gl, type, source) {
  // Allocate shader object
  const shader = gl.createShader(type);
  // Set source and compile
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  // Check for errors
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    glShaderCompileError(gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    return null;
  }

  return shader;
}

function initBuffer(gl) {
  // Create new VBO
  const vertexBuffer = gl.createBuffer();
  // Bind VBO
  gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(squareCoords), gl.STATIC_DRAW);

  return vertexBuffer;
}

function makeNewShaderProgram(gl, vertexShaderSrc, fragmentShaderSrc) {
  // Reset any errors
  resetErrorBox();

  const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vertexShaderSrc);
  const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSrc);

  // Create shader program
  if (vertexShader && fragmentShader) {
    const shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    // Check for link-time errors
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
      glLinkError(gl.getProgramInfoLog(shaderProgram));
      return null;
    }

    return shaderProgram;
  }
}

//
// Functions for the UI
//

// Display error if no WebGL support
function glNotSupported() {
  alert("WebGL is not supported on your device. This site will not work")
}

function resetEditor() {
  editor.setValue(fragmentShaderSource);
}

function saveShader() {
  const file = new Blob([editor.getValue()], {type: "x-shader/x-fragment"})
  const a = document.createElement("a");
  const url = URL.createObjectURL(file);
  a.href = url;
  a.download = "fragment.glsl";
  document.body.appendChild(a);
  a.click();
  setTimeout(function () {
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  }, 0);
}

function selectRandom() {
  const comboBox = document.getElementById("shader-selector");
  const numOptions = comboBox.options.length;

  const index = Math.floor((Math.random() * numOptions));
  comboBox.selectedIndex = index;
  editor.setValue(shaderSources[index]);
  recompileShader();
}

// Show errors in error box
function addError(error) {
  const errorBox = document.getElementById("error-display");
  errorBox.value = errorBox.value + "\n" + error;
}

// Reset error box
function resetErrorBox() {
  const errorBox = document.getElementById("error-display");
  errorBox.value = '';
}

// Display error if shader could not be compiled
function glShaderCompileError(error) {
  addError(error);
}

function glLinkError(error) {
  addError(error);
}

// Handle canvas mouse move
function handleMouseMoveCanvas(event, target) {
  target = target || event.target;
  const boundingRect = target.getBoundingClientRect();

  const x = (event.clientX - boundingRect.left) * (target.width / canvas.clientWidth);
  const y = (event.clientY - boundingRect.top) * (target.height / canvas.clientHeight);

  mousePos = {
    x,
    y
  }
}

// Set up combo box for selecting shader
function setUpSelector(shaderDescriptions, shaderSources) {
  const descriptionArray = shaderDescriptions.shaders;
  const comboBox = document.getElementById("shader-selector");

  for (let index = 0; index < descriptionArray.length; ++index) {
    const description = descriptionArray[index];
    const option = document.createElement('option');

    option.text = description.displayName + ": " + description.shortDescription;
    option.value = String(index);

    comboBox.add(option, index);
  }

  comboBox.onchange = (event) => {
    const index = event.target.value;
    editor.setValue(shaderSources[index]);
    recompileShader();
  };

  // Initially select a random value
  selectRandom();
}

// Update display of uniforms
function updateUniformDisplay(width, height, mousePos, time) {
  const widthDisplay = document.getElementById("canvas-width");
  const heightDisplay = document.getElementById("canvas-height");
  const mouseXDisplay = document.getElementById("mouse-x");
  const mouseYDisplay = document.getElementById("mouse-y");
  const timeDisplay = document.getElementById("time");

  widthDisplay.textContent = width;
  heightDisplay.textContent = height;
  mouseXDisplay.textContent = mousePos.x.toFixed(2);
  mouseYDisplay.textContent = mousePos.y.toFixed(2);
  timeDisplay.textContent = time.toFixed(2);
}

// Fetch all shader sources according to description file
async function fetchSources(shaderDescriptions) {
  // Make a promise for each source
  const descriptionArray = shaderDescriptions.shaders;
  const promises = descriptionArray.map((description) => fetch(description.path));
  return Promise.all(promises)
}

// Disable compile button if auto-recompile is enabled
function disableCompileIfAutoRecompile() {
  const compileButton = document.getElementById("compile-button");
  const checkBox = document.getElementById("auto-recompile");
  compileButton.disabled = checkBox.checked;
}

// Entry point to application
async function main() {
  // Get WebGL context
  const CANVAS_NAME = "shader1";
  const glCanvas = document.getElementById(CANVAS_NAME);
  const gl = glCanvas.getContext("webgl");
  // Set up mouse move handling to pass mouse position to canvas
  canvas = glCanvas;
  canvas.onmousemove = handleMouseMoveCanvas;
  if (gl === null) {
    glNotSupported();
    return;
  }

  // Reference to text area for changing the shader, set up CodeMirror
  const area = document.getElementById("editor");
  editor = CodeMirror.fromTextArea(area, {
    lineNumbers: true,
    mode: "x-shader/x-fragment"
  });
  // Auto-recompile if configured
  editor.on("change", () => {
    const checkBox = document.getElementById("auto-recompile");
    if (checkBox.checked) {
      recompileShader();
    }
  });
  // Disable compile button if checkbox is checked
  disableCompileIfAutoRecompile();

  // Fetch shader list headers
  // Do not cache
  const headers = new Headers();
  headers.append('pragma', 'no-cache');
  headers.append('cache-control', 'no-cache');
  const config = {
    method: 'GET',
    headers: headers
  };

  // Try to fetch list of shaders that are available from server,
  // then start rendering loop
  try {
    const SHADER_LIST_NAME = "shaders.json";
    const response = await fetch(SHADER_LIST_NAME, config);
    const shaderDescriptions = await response.json();

    // If successful, fetch all fragment shader sources and set up the selection combo-box
    const shaderSourceResponses = await fetchSources(shaderDescriptions);
    const textPromises = shaderSourceResponses.map((response) => response.text());
    shaderSources = await Promise.all(textPromises);

    // Set up shader selector combo box, default value 0
    setUpSelector(shaderDescriptions, shaderSources);

    // Create program, set globals
    currentShaderProgram = makeNewShaderProgram(gl, vertexShaderSource, shaderSources[0]);

    // Create VBO for default object (this won't change)
    const VBO = initBuffer(gl);

    // Start rendering
    requestAnimationFrame(render.bind({
      glContext: gl,
      VBO: VBO
    }));
  } catch (error) {
    console.log(error);
  }
}
