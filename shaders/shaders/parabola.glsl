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

// Get a parabola from 3 points. The formula can be derived
// by doing some linear algebra; it is quite complex.
float parabola(vec2 p1, vec2 p2, vec2 p3, float x) {
  float a =
  ((p3.x * (p2.y - p1.y) +
  p2.x * (p1.y - p3.y) +
  p1.x * (p3.y - p2.y))) /
  ((p1.x - p2.x) * (p1.x - p3.x) * (p2.x - p3.x));
  float b =
  (((p3.x * p3.x) * (p1.y - p2.y) +
  (p2.x * p2.x) * (p3.y - p1.y) +
  (p1.x * p1.x) * (p2.y - p3.y))) /
  ((p1.x - p2.x) * (p1.x - p3.x) * (p2.x - p3.x));
  float c =
  (((p2.x * p2.x) * (p3.x * p1.y - p1.x * p3.y)) +
  (p2.x * (p1.x * p1.x * p3.y - p3.x * p3.x * p1.y)) +
  ((p1.x * p3.x * p2.y) * (p3.x - p1.x))) /
  ((p1.x - p2.x) * (p1.x - p3.x) * (p2.x - p3.x));
  return a * (x * x) + b * x + c;
}

// Another way of getting a parabola, using Lagrange interpolation
float parabola2(vec2 p1, vec2 p2, vec2 p3, float x) {
  float term1 = (p1.y * (x - p2.x) * (x - p3.x)) / ((p1.x - p2.x) * (p1.x - p3.x));
  float term2 = (p2.y * (x - p1.x) * (x - p3.x)) / ((p2.x - p1.x) * (p2.x - p3.x));
  float term3 = (p3.y * (x - p1.x) * (x - p2.x)) / ((p3.x - p1.x) * (p3.x - p2.x));
  return term1 + term2 + term3;
}

void main() {
  vec2 normalizedFragCoord = getNormalizedFragCoord();
  float x = normalizedFragCoord.x;
  float y = normalizedFragCoord.y;

  // Makes a nice, moving parabola
  float val = parabola(vec2(0.2 + (0.125 * sin(u_time)), 0.0),
  vec2(0.5, 0.5 + (0.25 * sin(u_time))),
  vec2(0.8 + (0.125 * sin(u_time)), 0.0), x);

  float col = plot(val, y);
  gl_FragColor = vec4(vec3(col), 1.0);
}
