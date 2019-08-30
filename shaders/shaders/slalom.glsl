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

float circle_outline(vec2 origin, float radius, float thickness, vec2 coord) {
  float distance = length(origin - coord);
  return (1.0 - smoothstep(radius, radius + 0.02, distance)) -
  (1.0 - smoothstep(radius - thickness, radius - thickness + 0.02, distance));
}

float chain(float x_offset, vec2 coords) {
  vec2 initial = vec2(0.5 - x_offset, 0.85);
  initial = initial + vec2(0.35 * sin(u_time * 3.), 1.0 * abs(cos(u_time * 0.15)));
  float circle_outline_1 = circle_outline(initial, 0.1, 0.03, coords);
  float circle_outline_2 = circle_outline(initial + vec2(0.0, -0.2), 0.1, 0.02, coords);
  float circle_outline_3 = circle_outline(initial + vec2(0.0, -0.4), 0.1, 0.02, coords);
  float circle_outline_4 = circle_outline(initial + vec2(0.0, -0.6), 0.1, 0.02, coords);
  float circle_outline_5 = circle_outline(initial + vec2(0.0, -0.8), 0.1, 0.02, coords);
  float circle_outline_6 = circle_outline(initial + vec2(0.0, -1.0), 0.1, 0.02, coords);
  float circle_outline_7 = circle_outline(initial + vec2(0.0, -1.2), 0.1, 0.02, coords);
  float circle_outline_8 = circle_outline(initial + vec2(0.0, -1.4), 0.1, 0.02, coords);
  float circle_outline_9 = circle_outline(initial + vec2(0.0, -1.6), 0.1, 0.02, coords);
  float circle_outline_10 = circle_outline(initial + vec2(0.0, -1.8), 0.1, 0.02, coords);
  float circle_outline_11 = circle_outline(initial + vec2(0.0, -2.0), 0.1, 0.02, coords);
  return clamp(circle_outline_1 + circle_outline_2
  + circle_outline_3 + circle_outline_4 +
  circle_outline_5 + circle_outline_6 +
  circle_outline_7 + circle_outline_8 +
  circle_outline_9 + circle_outline_10 +
  circle_outline_11, 0.0, 1.0);
}

void main() {
  vec2 coords = getNormalizedFragCoord();
  vec2 initial = vec2(0.5, 0.85);
  float chain1 = chain(0.0, coords);
  float chain2 = chain(0.2, coords);
  float chain3 = chain(-0.2, coords);
  float chain4 = chain(0.4, coords);
  float chain5 = chain(-0.4, coords);
  float chain6 = chain(0.6, coords);
  float chain7 = chain(-0.6, coords);
  float chain8 = chain(0.8, coords);
  float chain9 = chain(-0.8, coords);

  vec3 color = vec3(0.6, 0.2, 0.2);

  gl_FragColor = vec4(color * clamp(chain1 + chain2 + chain3 +
  chain4 + chain5 + chain6 + chain7
  + chain8 + chain9, 0.0, 1.0),
  1.0);
}
