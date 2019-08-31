#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

vec2 getNormalizedFragCoord() {
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return normalizedFragCoords;
}

void tile(in vec2 coord, in float tiling_factor, out vec2 tiled_coord, out vec2 tile_indices) {
  tiled_coord = fract(coord * tiling_factor);
  tile_indices = floor(coord * tiling_factor);
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
  float tiling_factor = 5.0;
  tile(normalizedFragCoord, tiling_factor, tiled_coord, tile_indices);

  // Outer squares
  float rect1 = rectangle(vec2(0.0, 0.66), vec2(0.33, 1.0), tiled_coord);
  float rect2 = rectangle(vec2(0.0, 0.0), vec2(0.33, 0.33), tiled_coord);
  float rect3 = rectangle(vec2(0.66, 0.0), vec2(1.0, 0.33), tiled_coord);
  float rect4 = rectangle(vec2(0.66, 0.66), vec2(1.0, 1.0), tiled_coord);

  float shape_1 = clamp(rect1 + rect2 + rect3 + rect4, 0.0, 1.0);
  vec3 shape_1_color = vec3(0.2, 0.1, 0.3);

  // Other outer squares
  float rect5 = rectangle(vec2(0.0, 0.33), vec2(0.33, 0.66), tiled_coord);
  float rect6 = rectangle(vec2(0.33, 0.66), vec2(0.66, 1.0), tiled_coord);
  float rect7 = rectangle(vec2(0.33, 0.00), vec2(0.66, 0.33), tiled_coord);
  float rect8 = rectangle(vec2(0.66, 0.33), vec2(1.0, 0.66), tiled_coord);

  float shape_2 = clamp(rect5 + rect6 + rect7 + rect8, 0.0, 1.0);
  vec3 shape_2_color = vec3(0.1, 0.1, 0.3);

  // Middle square
  float rect9 = rectangle(vec2(0.33, 0.33), vec2(0.66, 0.66), tiled_coord);

  float shape_3 = clamp(rect9, 0.0, 1.0);
  vec3 shape_3_color = vec3(0.1, 0.1, 0.5);

  // Lines
  float line1 = rectangle(vec2(0.0, 0.1), vec2(1.0, 0.12), tiled_coord);
  float line2 = rectangle(vec2(0.0, 0.2), vec2(1.0, 0.22), tiled_coord);
  float line3 = rectangle(vec2(0.0, 0.52), vec2(1.0, 0.54), tiled_coord);
  float line4 = rectangle(vec2(0.0, 0.44), vec2(1.0, 0.46), tiled_coord);
  float line5 = rectangle(vec2(0.0, 0.88), vec2(1.0, 0.90), tiled_coord);
  float line6 = rectangle(vec2(0.0, 0.78), vec2(1.0, 0.80), tiled_coord);
  float line7 = rectangle(vec2(0.4, 0.00), vec2(0.42, 1.00), tiled_coord);
  float line8 = rectangle(vec2(0.58, 0.00), vec2(0.60, 1.00), tiled_coord);

  float lines = clamp(line1 + line2 + line3 +
  line4 + line5 + line6 +
  line7 + line8, 0.0, 1.0);
  vec3 line_color = vec3(1.0, 0.5, 0.1) * 2.0;

  vec3 final_pattern = mix(shape_1 * shape_1_color +
  shape_2 * shape_2_color +
  shape_3 * shape_3_color,
  lines * line_color, 0.2);

  gl_FragColor = vec4(final_pattern, 1.0);
}
