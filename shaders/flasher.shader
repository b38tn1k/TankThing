extern number time;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords );
    color[3] = color[3] * (1 + 0.5 * sin(time * 4));
    return pixel * color;
  }
