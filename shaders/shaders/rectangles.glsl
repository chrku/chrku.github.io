#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

// Transform fragment coordinates to 0...1 range
vec2 getNormalizedFragCoord() {
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return normalizedFragCoords;
}

// Function for drawing a filled rectangle at an arbitary location.
// Returns a number between 0 and 1, where 1 -> on rectangle border
// and 0 -> not on rectangle border
float rectangle(vec2 lower_left_corner, vec2 upper_right_corner, vec2 coords) {
  return (step(lower_left_corner.x, coords.x) - step(upper_right_corner.x, coords.x)) *
  (step(lower_left_corner.y, coords.y) - step(upper_right_corner.y, coords.y));
}

// Function for drawing a rectangle frame at an arbitary location.
// Returns a number between 0 and 1, where 1 -> on rectangle border
// and 0 -> not on rectangle border
float rectangle_frame(vec2 lower_left_corner, vec2 upper_right_corner, float thickness, vec2 coords) {
  return (step(lower_left_corner.x, coords.x) - step(upper_right_corner.x, coords.x)) *
  (step(lower_left_corner.y, coords.y) - step(upper_right_corner.y, coords.y))// Rectangle inner
  *// Mask with frame
  clamp(((1.0 - step(lower_left_corner.x + thickness, coords.x)) + step(upper_right_corner.x - thickness, coords.x)) +
  ((1.0 - step(lower_left_corner.y + thickness, coords.y)) + step(upper_right_corner.y - thickness, coords.y)), 0.0, 1.0);
}

void main() {
  vec2 coords = getNormalizedFragCoord();
  vec3 color = vec3(0.4, 0.1, 0.3);
  float rect1 = rectangle(vec2(0.1 + 0.1 * sin(u_time), 0.2), vec2(0.2 + 0.1 * sin(u_time), 0.3), coords);
  float rect2 = rectangle_frame(vec2(0.6, 0.5 + 0.2 * cos(u_time)), vec2(0.7, 0.8 + 0.2 * cos(u_time)), 0.02, coords);
  float rect3 = rectangle(vec2(0.8 + 0.1 * sin(u_time), 0.8), vec2(0.9 + 0.1 * sin(u_time), 0.9), coords);
  float rect4 = rectangle_frame(vec2(0.8, 0.1 + 0.3 * sin(u_time)), vec2(0.9, 0.5 + 0.4 * sin(u_time)), 0.02, coords);
  float rect5 = rectangle_frame(vec2(0.4 + 0.2 * sin(u_time), 0.2), vec2(0.7 + 0.2 * sin(u_time), 0.4), 0.02, coords);
  float rect6 = rectangle_frame(vec2(0.1, 0.7 + 0.3 * sin(u_time)), vec2(0.5, 0.9 + 0.3 * sin(u_time)), 0.02, coords);
  float result = clamp(rect1 + rect2 + rect3 + rect4 + rect5 + rect6, 0.0, 1.0);

  gl_FragColor = vec4(color * result, 1.0);
}
