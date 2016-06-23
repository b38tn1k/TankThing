vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords );
    number average = (color[0] + color[2] + color[3]) / 3;
    color[0] = 0.3 * color[0] + 0.7 * average;
    color[1] = 0.3 * color[1] + 0.7 * average;
    color[2] = 0.3 * color[2] + 0.7 * average;
    return pixel * color;
  }
