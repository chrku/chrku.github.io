#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

#define PI 3.141592

// Transform fragment coordinates to 0...1 range
vec2 getNormalizedFragCoord() {
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return normalizedFragCoords;
}

// Get polar coordinates with an arbitrary origin
// Will be used for distance fields
void getPolarCoords(in vec2 origin, in vec2 p, out float radius, out float angle) {
  vec2 vector_to_point = p - origin;
  radius = length(vector_to_point);
  angle = atan(vector_to_point.y, vector_to_point.x);
}

float n_gon(vec2 origin, float N, float radius, float tilt, vec2 coords) {
  float angle;
  float dist;
  // Get polar coordinates from center defined by origin
  getPolarCoords(origin, coords, dist, angle);
  angle = angle + tilt;
  // Angle is now in the range -PI to PI; we want to rescale this to -0.5N...0.5N
  float scaled_angle = (angle /  (2.0 * PI)) * N;
  float cos_val = cos(floor(scaled_angle + 0.5) * ((2.0 * PI) / N) - angle);
  return smoothstep(radius, radius + 0.01, dist * cos_val);
}

void main() {
  vec2 coords = getNormalizedFragCoord();
  float test = n_gon(vec2(0.3, 0.6), 7.0, 0.1, u_time * 3.0, coords);
  float test1 = n_gon(vec2(0.5, 0.3), 3.0, 0.1, u_time * 3.0, coords);
  float test2 = n_gon(vec2(0.8, 0.6), 4.0, 0.1, u_time * 3.0, coords);
  float test3 = n_gon(vec2(0.15, 0.2), 5.0, 0.1, u_time * 3.0, coords);
  float test4 = n_gon(vec2(0.3, 0.6), 7.0, 0.1, u_time * 2.0, coords);
  float test5 = n_gon(vec2(0.3, 0.6), 7.0, 0.1, u_time * 1.0, coords);
  float test6 = n_gon(vec2(0.3, 0.9), 6.0, 0.05, u_time * 6.0, coords);


  gl_FragColor = vec4(vec3(clamp(test * test1 * test2 * test3 * test4 * test5 * test6, 0.0, 1.0)), 1.0);
}
