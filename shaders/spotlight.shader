extern number xy[2];
extern number radius;
// extern number blur_radius;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel(texture, texture_coords );
  number x = (screen_coords[0] - xy[0]) * (screen_coords[0] - xy[0]);
  number y = (screen_coords[1] - xy[1]) * (screen_coords[1] - xy[1]);
  number root = sqrt(x + y);
  number reduction = 0.95;
  number blur_radius = 5;
  if (root > radius) {
    color[0] = (color[0] * reduction);
    color[1] = (color[1] * reduction);
    color[2] = (color[2] * reduction);
    // if (root < radius + blur_radius) {
    //   number blur_value =  (1 - reduction) * (1 - (root - radius) / blur_radius) + reduction;
    //   color[0] = (color[0] * blur_value);
    //   color[1] = (color[1] * blur_value);
    //   color[2] = (color[2] * blur_value);
    // }
    }
    return pixel * color;
  }
