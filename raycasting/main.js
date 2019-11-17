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

const fragmentShaderSource = `
  #ifdef GL_ES
  precision mediump float;
  #endif
  
  #define ITERATIONS 500
  #define STEP_SIZE 0.01
  
  uniform float u_time;
  uniform vec2 u_resolution;
 
  mat3 getRotationMatrixY(float angle) {
    return mat3(cos(angle), 0.0, sin(angle),
                0.0, 1.0, 0.0,
                -sin(angle), 0.0, cos(angle));
  }
  
  vec3 cameraPosition = vec3(0.0, 0.0, 0.3);
  float focalLength = 1.0;
  
  vec2 getNormalizedFragCoord() {
    vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
      gl_FragCoord.y / u_resolution.y);
    return normalizedFragCoords;
  }
  
  vec3 createRay() {
    // Get fragment coordinate
    vec2 coord = getNormalizedFragCoord();
    vec3 rotatedCamera = cameraPosition * getRotationMatrixY(u_time);
    float a = u_resolution.x / u_resolution.y;
    // Get lower left corner of viewport
    vec3 lowerLeftCorner = rotatedCamera - vec3((a / 2.0), 0.0, 0.0)
      - vec3(0.0, 0.5, 0.0) + vec3(0.0, 0.0, focalLength);
    vec3 viewPortPoint = lowerLeftCorner + vec3(a * coord.x, 0.0, 0.0)
      + vec3(0.0, coord.y, 0.0);
    return viewPortPoint - rotatedCamera;
  }
  
  float sphere(vec3 origin, float radius, vec3 p) {
    return length(origin - p) - radius;
  }
  
  float torus(vec3 origin, float inner, float outer, vec3 point) {
    vec3 p = point - origin;
    vec2 q = vec2(length(p.xz) - inner, p.y);
    return length(q) - outer;
  }
  
  vec3 rayMarch(vec3 ray) {
    vec3 rotatedCamera = cameraPosition * getRotationMatrixY(u_time);
    for (int i = 0; i < ITERATIONS; ++i) {
      vec3 point = rotatedCamera + STEP_SIZE * float(i) * ray;
      // Sphere at (0.0, 0.0, 2.0)
      vec3 sphere_origin = vec3(-0.1, -0.2, 2.0);
      vec3 torus_origin = vec3(0.4, 0.3, 2.0);
      if (sphere(sphere_origin, 0.3, point) <= 0.0) {
        vec3 normal = normalize(point - sphere_origin);
        vec3 lightDir = normalize(rotatedCamera - point);
        return vec3(1.0, 1.0, 1.0) * clamp(dot(normal, lightDir), 0.0, 1.0);
      }
      if (torus(torus_origin, 0.3, 0.1, point) <= 0.0) {
        vec3 grad = vec3(
          (torus(torus_origin, 0.3, 0.1, point + vec3(0.001, 0.0, 0.0)) 
            - torus(torus_origin, 0.3, 0.1, point - vec3(0.001, 0.0, 0.0))),
          (torus(torus_origin, 0.3, 0.1, point + vec3(0.0, 0.001, 0.0)) 
            - torus(torus_origin, 0.3, 0.1, point - vec3(0.0, 0.001, 0.0))),
          (torus(torus_origin, 0.3, 0.1, point + vec3(0.0, 0.0, 0.001)) 
            - torus(torus_origin, 0.3, 0.1, point - vec3(0.0, 0.0, 0.001))));
        vec3 normal = normalize(grad);
        vec3 lightDir = normalize(rotatedCamera - point);
        return vec3(1.0, 1.0, 1.0) * clamp(dot(normal, lightDir), 0.0, 1.0);
      }
    }
    
    return vec3(0.0, 0.0, 0.0);
  }

  void main() {
    vec3 ray = createRay();
    vec3 col = rayMarch(ray);
    gl_FragColor = vec4(col, 1.0);
  }
`;

// Coordinates for a square plane
const squareCoords = [
  -1.0, 1.0,
  1.0, 1.0,
  -1.0, -1.0,
  1.0, -1.0
];

let canvas = null;

//
// Functions for graphics & WebGL
//

function drawScene(time, gl, shaderProgram, VBO, width, height) {
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

  gl.uniform2f(gl.getUniformLocation(shaderProgram, 'u_resolution'), width, height);
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

  // Check if the shader source changed since last render
  // if (shaderSourceChanged) {
  //  setNewShader(gl);
  // }

  drawScene(time, gl, currentShaderProgram, VBO, canvasWidth, canvasHeight);
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
    alert(gl.getShaderInfoLog(shader));
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

//
// Functions for the UI
//

// Display error if no WebGL support
function glNotSupported() {
  alert("WebGL is not supported on your device. This site will not work")
}

// Entry point to application
async function main() {
  // Get WebGL context
  const CANVAS_NAME = "shader1";
  const glCanvas = document.getElementById(CANVAS_NAME);
  const gl = glCanvas.getContext("webgl");
  // Set up mouse move handling to pass mouse position to canvas
  canvas = glCanvas;
  if (gl === null) {
    glNotSupported();
    return;
  }

  // Create program, set globals
  currentShaderProgram = makeNewShaderProgram(gl, vertexShaderSource, fragmentShaderSource);

  // Create VBO for default object (this won't change)
  const VBO = initBuffer(gl);

  // Start rendering
  requestAnimationFrame(render.bind({
    glContext: gl,
    VBO: VBO
  }));
}
