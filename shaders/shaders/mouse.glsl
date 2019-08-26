#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_mouse;
uniform vec2 u_resolution;

// Get L2 distance to mouse, between 0 and 1
float getDistanceToMouse() {
  vec2 normalizedMouseCoords = vec2(u_mouse.x / u_resolution.x,
  u_mouse.y / u_resolution.y);
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return length(normalizedFragCoords - normalizedMouseCoords);
}

void main() {
  gl_FragColor = vec4(abs(sin(getDistanceToMouse() * u_time)), 0.5, 0.3, 1.0);
}
