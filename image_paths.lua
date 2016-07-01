local tank_image_paths = {}
blue = {"tank_selected.png", "blue_tank_base.png", "blue_tank_turrent.png", "blue_missile.png"}
red = {"tank_selected.png", "red_tank_base.png", "red_tank_turrent.png", "red_missile.png"}
green = {"tank_selected.png", "green_tank_base.png", "green_tank_turrent.png", "green_missile.png"}
black = {"tank_selected.png", "black_tank_base.png", "black_tank_turrent.png", "black_missile.png"}
table.insert(tank_image_paths, blue)
table.insert(tank_image_paths, red)
table.insert(tank_image_paths, green)
table.insert(tank_image_paths, black)
local small_tank_image_paths = {}
blue = {"small_tank_selected.png", "small_blue_tank_base.png", "small_blue_tank_turrent.png", "small_blue_missile.png"}
red = {"small_tank_selected.png", "small_red_tank_base.png", "small_red_tank_turrent.png", "small_red_missile.png"}
green = {"small_tank_selected.png", "small_green_tank_base.png", "small_green_tank_turrent.png", "small_green_missile.png"}
black = {"small_tank_selected.png", "small_black_tank_base.png", "small_black_tank_turrent.png", "small_black_missile.png"}
table.insert(small_tank_image_paths, blue)
table.insert(small_tank_image_paths, red)
table.insert(small_tank_image_paths, green)
table.insert(small_tank_image_paths, black)

return {tank_image_paths, small_tank_image_paths}
