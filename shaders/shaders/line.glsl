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
  float above = smoothstep(val, val + 0.06, y);
  // Same as below, but we start at a lower threshold
  // and flip the color
  float below = 1.0 - smoothstep(val - 0.06, val, y);
  // => We only get black between y - 0.01 and y + 0.01
  return above + below;
}

void main() {
  vec2 normalizedFragCoord = getNormalizedFragCoord();
  float x = normalizedFragCoord.x;
  float y = normalizedFragCoord.y;
  float val = x;

  float col = plot(val, y);
  gl_FragColor = vec4(vec3(col), 1.0);
}
