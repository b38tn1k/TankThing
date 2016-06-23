vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords );
    number m = color[0];
    number gain = 0.9;
    if (m < color[1]) {
      m = color[1];
    }
    if (m < color[2]) {
      m = color[2];
    }
    // if (m == color[0]) {
      // color[1] = gain * color[1];
      // color[2] = gain * color[2];
    // }
    if (m == color[1]) {
      color[2] = gain * color[2];
      color[0] = gain * color[0];
    }
    if (m == color[2]) {
      color[0] = gain * color[0];
      color[1] = gain * color[1];
    }
    return pixel * color;
  }
