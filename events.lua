function love.mousepressed(x, y, button, istouch)
  if pause == true then
    if menu:new_game_button(x, y) == true then
      love.graphics.clear( )
      screen.width, screen.height = love.window.getDesktopDimensions(1)
      worldseed = world:newSeed()
      path_map = world:generate()
      world:makeCanvas(myShader)
      tanks = {}
      hidden_tanks = {}
      tank1 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, path_map, path_resolution, small_tank_image_paths[1])
      tank2 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, path_map, path_resolution, small_tank_image_paths[2])
      tank3 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, path_map, path_resolution, small_tank_image_paths[3])
      tank4 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, path_map, path_resolution, small_tank_image_paths[4])
      random_node = math.random( #path_map)
      tank1:init(1, path_map[random_node].x * path_resolution, path_map[random_node].y * path_resolution, math.random())
      random_node = math.random( #path_map)
      tank2:init(2, path_map[random_node].x * path_resolution, path_map[random_node].y * path_resolution, math.random())
      random_node = math.random( #path_map)
      tank3:init(3, path_map[random_node].x * path_resolution, path_map[random_node].y * path_resolution, math.random())
      random_node = math.random( #path_map)
      tank4:init(4, path_map[random_node].x * path_resolution, path_map[random_node].y * path_resolution, math.random())
      table.insert(tanks, tank1)
      table.insert(tanks, tank2)
      table.insert(tanks, tank3)
      table.insert(tanks, tank4)
      pause = false
    end
    -- do menu stuff
  else
    if button == 'l' then
      newly_selected = false
      for j, tank in ipairs(tanks) do
        if tank:check_for_collision(x, y) then
          for j, other_tank in ipairs(tanks) do
            other_tank.selected = false
          end
          tank.selected = true
          newly_selected = true
        end
      end
      for j, tank in ipairs(tanks) do
        if tank.selected == true and newly_selected == false then
          tank:addWaypoint(x, y)
        end
      end
    end
  end
end

function love.keyreleased(key)
  if pause == true then
    -- do menu stuff
  else
    if key == " " then
      for j, tank in ipairs(tanks) do
        if tank.selected == true then
          projectile = Projectile.create(tank:fire_main_weapon())
          table.insert(projectiles, projectile)
        end
      end
    end
  end
  if key == "escape" then
    pause = not pause
  end
  if key == 'tab' then
    debug = not debug
  end
end

function love.resize(w, h)
  love.graphics.clear()
  screen.width, screen.height = w, h
  world = World.create(screen.width, screen.height, path_resolution, render_resolution)
  world.seed = worldseed
  new_path_map = world:generate(myShader)
  world:makeCanvas(myShader)
  menu = Menu.create(screen.width, screen.height, tank_image_paths, "logo.png")
  to_remove = {}
  for i, tank in ipairs(hidden_tanks) do
    tank.path_map = new_path_map
    if tank.x.position < screen.width or tank.y.position < screen.height then
      table.insert(tanks, tank)
      table.insert(to_remove, i)
    end
  end
  for i, index in ipairs(to_remove) do
    table.remove(hidden_tanks, index)
  end
  to_remove = {}
  for j, tank in ipairs(tanks) do
    tank.path_map = new_path_map
    if tank.x.position > screen.width or tank.y.position > screen.height then
      table.insert(hidden_tanks, tank)
      table.insert(to_remove, j)
    else
      tank.x.bound = screen.width
      tank.y.bound = screen.height
    end
  end
  for i, index in ipairs(to_remove) do
    table.remove(tanks, index)
  end
end
