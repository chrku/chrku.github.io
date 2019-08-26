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

// Get renormalized sine value (between 0 and amplitude)
float renormalized_sine(float x, float phase_shift, float freq, float amplitude) {
  return amplitude * (((sin((x + phase_shift) * freq) + 1.) * 0.45) + 0.05);
}

// Function that returns values that are close to 1 if y == val
float plot(float val, float y) {
  // Anything above val + 0.01 is white, anything below
  // y is black
  float above = smoothstep(val, val + 0.02, y);
  // Same as below, but we start at a lower threshold
  // and flip the color
  float below = 1.0 - smoothstep(val - 0.02, val, y);
  // => We only get black between y - 0.01 and y + 0.01
  return above + below;
}

// 1 if a <= x <= b, otherwise 0
// requires a < b
float activeBetween(float a, float b, float x) {
  return step(a, x) - step(b, x);
}

// Interpolate between c and d if a <= x <= b, else 0
// requires a < b
float interpolateBetween(float a, float b, float c, float d, float x) {
  return mix(c, d, (x - a) * (d - c) / (b - a)) * activeBetween(a, b, x);
}

// Interpolate between c and d if a <= x <= b, else 0
// requires b > a, flips result for falling curve
float interpolateBetweenFall(float a, float b, float c, float d, float x) {
  return (1.0 - mix(d, c, (x - a) * (c - d) / (b - a))) * activeBetween(a, b, x);
}


void main() {
  vec2 normalizedFragCoord = getNormalizedFragCoord();
  float x = renormalized_sine(normalizedFragCoord.x, u_time, 1.5, 1.0);
  float y = normalizedFragCoord.y;

  // Create rainbow effect by piecewise interpolation of r, g and b
  float red = interpolateBetweenFall(0.0, 0.25, 1.0, 0.0, x) +
  interpolateBetween(0.25, 0.5, 0.0, 0.0, x) +
  interpolateBetween(0.5, 0.75, 0.0, 1.0, x) +
  interpolateBetween(0.75, 1.0, 1.0, 1.0, x);
  float blue = interpolateBetween(0.0, 0.25, 1.0, 1.0, x) +
  interpolateBetweenFall(0.25, 0.5, 1.0, 0.0, x) +
  interpolateBetween(0.5, 0.75, 0.0, 0.0, x) +
  interpolateBetween(0.75, 1.0, 0.0, 0.0, x);
  float green = interpolateBetween(0.0, 0.25, 0.0, 0.0, x) +
  interpolateBetween(0.25, 0.5, 0.0, 1.0, x) +
  interpolateBetween(0.5, 0.75, 1.0, 1.0, x) +
  interpolateBetweenFall(0.75, 1.0, 1.0, 0.0, x);

  float col = 0.33 * plot(red, y) + 0.33 * plot(blue, y) + 0.33 * plot(green, y);
  gl_FragColor = vec4(vec3(red, green, blue), 1.0);
}
