#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

#define PI 3.141592

mat2 rotate2d(float angle){
  return mat2(cos(angle), -sin(angle),
  sin(angle), cos(angle));
}

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

// Function for drawing a rectangle frame at an arbitary location.
// Returns a number between 0 and 1, where 1 -> on rectangle border
// and 0 -> not on rectangle border
float rectangle_frame(vec2 lower_left_corner, vec2 upper_right_corner, float thickness, float tilt, vec2 coords) {
  // Tilt the rectangle (linear transformation using Translate + Rotate + Inv. Trans
  // Could theoretically do this using all matrices if I were using homogenous coords, easier like this
  vec2 center = 0.5 * lower_left_corner + 0.5 * upper_right_corner;
  coords = (coords - center) * rotate2d(tilt) + center;

  // Draw rectangle frame
  return (step(lower_left_corner.x, coords.x) - step(upper_right_corner.x, coords.x)) *
  (step(lower_left_corner.y, coords.y) - step(upper_right_corner.y, coords.y))// Rectangle inner
  *// Mask with frame
  clamp(((1.0 - step(lower_left_corner.x + thickness, coords.x)) + step(upper_right_corner.x - thickness, coords.x)) +
  ((1.0 - step(lower_left_corner.y + thickness, coords.y)) + step(upper_right_corner.y - thickness, coords.y)), 0.0, 1.0);
}

void main() {
  // Tile the space
  vec2 normalizedFragCoord = getNormalizedFragCoord();
  vec2 tiled_coord;
  vec2 tile_indices;
  float tiling_factor = 3.0 + 5.0 * abs(sin(u_time));
  // Center and rotate
  normalizedFragCoord -= vec2(0.5, 0.5);
  normalizedFragCoord = rotate2d(sin(u_time) * PI) * normalizedFragCoord;
  tile(normalizedFragCoord, tiling_factor, tiled_coord, tile_indices);

  float rect1 = rectangle_frame(vec2(0.3, 0.3), vec2(0.7, 0.7), 0.02, PI / 4.0, tiled_coord);
  float rect2 = rectangle(vec2(0.49, 0.75), vec2(0.51, 1.0), tiled_coord);
  float rect3 = rectangle(vec2(0.49, 0.00), vec2(0.51, 0.25), tiled_coord);
  float rect4 = rectangle(vec2(0.00, 0.49), vec2(0.25, 0.51), tiled_coord);
  float rect5 = rectangle(vec2(0.75, 0.49), vec2(1.0, 0.51), tiled_coord);
  float pattern = clamp(rect1 + rect2 + rect3 + rect4 + rect5, 0.0, 1.0);
  vec3 pattern_color = vec3(0.4, 0.9, 0.7);

  gl_FragColor = vec4(mix(pattern * pattern_color, vec3(0.6, 0.2, 0.4), 0.5), 1.0);
}
