#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

#define ITERATIONS 500
#define PI 3.141592


// Transform fragment coordinates to 0...1 range
vec2 getNormalizedFragCoord() {
  vec2 normalizedFragCoords = vec2(gl_FragCoord.x / u_resolution.x,
  gl_FragCoord.y / u_resolution.y);
  return normalizedFragCoords;
}

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


vec3 mandelbrot(vec2 coords) {
  // Transform coordinates to -0.5 to 0.5 range
  vec2 c = vec2((coords.x * 3.5) - 2.5, (coords.y - 0.5) * 2.0);
  // Calculate mandelbrot fractal for a fixed amount
  // of iterations
  // We pretend that our coordinates are in the complex plane
  // and calculate the iterative formula
  // For more details, https://en.wikipedia.org/wiki/Mandelbrot_set
  vec2 z = vec2(0.0);
  for (int i = 0; i < ITERATIONS; ++i) {
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
  }
  return hsv2rgb(vec3(atan(z.y, z.x) / (2.0 * PI), clamp(length(z) * 4.0, 0.0, 1.0), 1.0));
}

void main() {
  vec2 coords = getNormalizedFragCoord();

  gl_FragColor = vec4(mandelbrot(coords), 1.0);
}
