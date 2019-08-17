
// Call entry point
window.onload = main;

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

let editor = null;

// Display error if no WebGL support
function glNotSupported() {

}

// Recompile shader
function recompileShader() {
  shaderSourceChanged = true;
}

// Display error if shader could not be compiled
function glShaderCompileError(error) {
  alert(error);
}

function glLinkError(error) {
  alert(error);
}

function drawScene(time, gl, shaderProgram, VBO) {
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

  // Set uniforms
  gl.uniformMatrix4fv(gl.getUniformLocation(shaderProgram, 'uProjectionMatrix'), false, projection);
  gl.uniformMatrix4fv(gl.getUniformLocation(shaderProgram, 'uViewMatrix'), false, view);
  gl.uniformMatrix4fv(gl.getUniformLocation(shaderProgram, 'uModelMatrix'), false, model);

  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
}

// This is called each frame using requestAnimationFrame()
function render(time) {
  // The GL context is bound to the function
  const gl = this.glContext;
  const VBO = this.VBO;
  // Convert time to seconds
  time *= 0.001;

  // Check if the shader source changed since last render
  if (shaderSourceChanged) {
    // Try recompiling new shaders
    const currentShaderSource = editor.getValue();
    const newProgram = makeNewShaderProgram(gl, vertexShaderSource, currentShaderSource);
    if (newProgram) {
      currentShaderProgram = newProgram;
    }
    shaderSourceChanged = false;
  }

  drawScene(time, gl, currentShaderProgram, VBO);

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

// Entry point to application
async function main() {
  // Get WebGL context
  const shaderName = "shader1";

  const canvas = document.getElementById(shaderName);
  const gl = canvas.getContext("webgl");

  if (gl === null) {
    glNotSupported();
    return;
  }

  // Fetch shader sources
  // Do not cache
  const headers = new Headers();
  headers.append('pragma', 'no-cache');
  headers.append('cache-control', 'no-cache');

  const config = {
    method: 'GET',
    headers: headers
  };

  // Reference to text area for changing the shader
  const area = document.getElementById("editor");
  editor = CodeMirror.fromTextArea(area, {
    lineNumbers: true,
    mode: "glsl"
  });

  try {
    // Fetch default shader
    const response = await fetch(shaderName + ".glsl", config);
    const shaderText = await response.text();

    // Create program, set globals
    currentShaderProgram = makeNewShaderProgram(gl, vertexShaderSource, shaderText);

    // Create VBO for default object (this won't change)
    const VBO = initBuffer(gl);

    // Start rendering
    requestAnimationFrame(render.bind({
      glContext: gl,
      VBO: VBO
    }));

    // Set canvas text to shader
    editor.setValue(shaderText);
  } catch (error) {
    console.log(error);
  }
}
