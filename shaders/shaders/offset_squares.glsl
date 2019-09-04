#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

mat2 rotate2d(float angle){
  return mat2(cos(angle), -sin(angle),
  sin(angle), cos(angle));
}

vec2 getNormalizedFragCoord() {
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return normalizedFragCoords;
}

// Return a tiled coordinate. This is a coordinate between 0.0 and 1.0,
// which is tiled across the space
vec2 tile(vec2 coord, float tiling_factor) {
  return fract(coord * tiling_factor);
}

// Get tile indices of coordinate
vec2 getTileIndices(vec2 coord, float tiling_factor) {
  return floor(coord * tiling_factor);
}

// Function for drawing a filled rectangle at an arbitary location.
// Returns a number between 0 and 1, where 1 -> on rectangle border
// and 0 -> not on rectangle border
float rectangle(vec2 lower_left_corner, vec2 upper_right_corner, vec2 coords) {
  return (step(lower_left_corner.x, coords.x) - step(upper_right_corner.x, coords.x)) *
  (step(lower_left_corner.y, coords.y) - step(upper_right_corner.y, coords.y));
}

void main() {
  // Tile the space
  vec2 normalizedFragCoord = getNormalizedFragCoord();
  vec2 tiled_coord;
  vec2 tile_indices;
  float tiling_factor = 17.0;
  // Center and rotate
  tile_indices = getTileIndices(normalizedFragCoord, tiling_factor);
  tiled_coord = tile(normalizedFragCoord, tiling_factor);

  // This allows conditional drawing based off of the tile index
  float activate_x_odd = step(1.0, mod(tile_indices.x + 1.0, 2.0));
  float activate_x_even = step(1.0, mod(tile_indices.x, 2.0));
  float activate_y_odd = step(1.0, mod(tile_indices.y + 1.0, 2.0));
  float activate_y_even = step(1.0, mod(tile_indices.y, 2.0));

  // Additional activates
  float activate_y_middle = step(2.00, mod(tile_indices.y, 3.0));
  float activate_y_non_middle = 1.0 - step(2.00, mod(tile_indices.y, 3.0));

  // X-coordinate shaping function
  float t_mod_2 = mod(u_time, 2.0);
  float x_shape =
  (step(0.0, mod(u_time, 10.)) - step(2.0, mod(u_time, 10.))) * smoothstep(0.0, 2.0, t_mod_2) +
  (step(2.0, mod(u_time, 10.)) - step(8.0, mod(u_time, 10.))) +
  (step(8.0, mod(u_time, 10.)) - step(10.0, mod(u_time, 10.))) * (1. - smoothstep(0.0, 2.0, t_mod_2));
  ;
  float y_shape = (step(0.0, mod(u_time, 10.)) - step(2.0, mod(u_time, 10.))) * 0.0 +
  (step(2.0, mod(u_time, 10.)) - step(4.0, mod(u_time, 10.))) * smoothstep(0.0, 2.0, t_mod_2) +
  (step(4.0, mod(u_time, 10.)) - step(6.0, mod(u_time, 10.))) +
  (step(6.0, mod(u_time, 10.)) - step(8.0, mod(u_time, 10.))) * (1. - smoothstep(0.0, 2.0, t_mod_2));

  // Make rects move across tiles
  float begin_x_odd = (activate_y_middle * x_shape) * activate_x_odd;
  float end_x_odd = 1.0 * activate_x_odd;
  float begin_x_even = 0.0 * activate_x_even;
  float end_x_even = (activate_y_middle * x_shape) * activate_x_even;

  float begin_y_odd = activate_y_non_middle * y_shape  * activate_y_odd;
  float end_y_odd = 1.0 * activate_y_odd;
  float begin_y_even = 0.0 * activate_y_even;
  float end_y_even = activate_y_non_middle * y_shape * activate_y_even;

  float rect1 = rectangle(vec2(begin_x_even + begin_x_odd, begin_y_odd + begin_y_even), vec2(end_x_even + end_x_odd, end_y_odd + end_y_even), tiled_coord);
  float pattern = clamp(rect1, 0.0, 1.0);

  // Give the pattern an appropriate color depending on the tile indices
  vec3 pattern_color = mix(vec3(0.5, 0.5, 0.5), vec3(1.0, 1.0, 1.0), activate_y_middle);

  gl_FragColor = vec4(pattern * pattern_color, 1.0);
}
