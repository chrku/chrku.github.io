#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.141592

uniform float u_time;
uniform vec2 u_resolution;

// Conversion functions from https://stackoverflow.com/questions/15095909/from-rgb-to-hsv-in-opengl-glsl
// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Transform fragment coordinates to 0...1 range
vec2 getNormalizedFragCoord() {
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return normalizedFragCoords;
}

// Circle mask: Circle centered at point p with radius r. Anything within gets value
// 1, anything outside 0
float circleMask(vec2 p, float r, vec2 test) {
  float distance_to_center = length(p - test);
  return 1.0 - smoothstep(r, r + 0.02, distance_to_center);
}

void main() {
  vec2 coords = getNormalizedFragCoord();

  // Transform to polar coordinates with 0.5, 0.5 as center
  vec2 to_center = vec2(0.5) - coords;
  float radius = length(to_center);
  // Remap radius from 0...0.5 to 0...1
  radius = radius * 2.0;
  // Get angle using atan()
  float angle = atan(to_center.y, to_center.x);
  // Add u_time for animation
  angle = angle + u_time * 2.0;

  // The angle ranges from -PI to PI; we want to remap this to 0...1
  angle = (angle + PI) / (2.0 * PI);

  // Transform this two HSV: the hue is determined by the angle, the saturation by
  // the radius and the brightness is a constant 0.9
  // Mask this with a circle to get a wheel-like shape
  vec3 color = hsv2rgb(vec3(angle, radius, 0.9)) * circleMask(vec2(0.5), 0.4, coords) +
  (1.0 - circleMask(vec2(0.5), 0.4, coords)) * vec3(1.0, 1.0, 1.0);

  gl_FragColor = vec4(color, 1.0);
}
