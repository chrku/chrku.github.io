#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

void main() {
  float x = sin(u_time);
  float val = pow(x, 2.);
  vec3 col1 = vec3(0.8, 0.3, 0.2);
  vec3 col2 = vec3(0.1, 0.1, 0.6);

  gl_FragColor = vec4(mix(col1, col2, val), 1.0);
}
