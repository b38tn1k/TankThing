function love.mousepressed(x, y, button, istouch)
  if game.pause == true then
    if game.menu:new_game_button(x, y) == true then
      love.graphics.clear( )
      screen.width, screen.height = love.window.getDesktopDimensions(1)
      game.worldseed = game.world:newSeed()
      game.path_map = game.world:generate()
      game.world:makeCanvas(1)
      game.tanks = {}
      game.hidden_tanks = {}
      tank1 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.blue)
      tank2 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.red)
      tank3 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.black)
      tank4 = Tank.create(screen.width, screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.green)
      random_node = math.random( #game.path_map)
      tank1:init(1, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
      random_node = math.random( #game.path_map)
      tank2:init(2, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
      random_node = math.random( #game.path_map)
      tank3:init(3, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
      random_node = math.random( #game.path_map)
      tank4:init(4, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
      table.insert(game.tanks, tank1)
      table.insert(game.tanks, tank2)
      table.insert(game.tanks, tank3)
      table.insert(game.tanks, tank4)
      game.pause = false
    end
    -- do menu stuff
  else
    if button == 'l' then
      newly_selected = false
      for j, tank in ipairs(game.tanks) do
        if tank:check_for_collision(x, y) then
          for j, other_tank in ipairs(game.tanks) do
            other_tank.selected = false
          end
          tank.selected = true
          newly_selected = true
        end
      end
      for j, tank in ipairs(game.tanks) do
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
      for j, tank in ipairs(game.tanks) do
        if tank.selected == true then
          projectile = Projectile.create(tank:fire_main_weapon())
          table.insert(game.projectiles, projectile)
        end
      end
    end
  end
  if key == "escape" then
    game.pause = not game.pause
  end
  if key == 'tab' then
    game.debug = not game.debug
  end
end

function love.resize(w, h)
  love.graphics.clear()
  screen.width, screen.height = w, h
  game.world = World.create(screen.width, screen.height, game.path_resolution, render_resolution)
  game.world.seed = game.worldseed
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  game.menu = Menu.create(screen.width, screen.height, game.assets)
  to_remove = {}
  for i, tank in ipairs(game.hidden_tanks) do
    tank.path_map = game.path_map
    if tank.x.position < screen.width or tank.y.position < screen.height then
      table.insert(game.tanks, tank)
      table.insert(to_remove, i)
    end
  end
  for i, index in ipairs(to_remove) do
    table.remove(game.hidden_tanks, index)
  end
  to_remove = {}
  for j, tank in ipairs(game.tanks) do
    tank.path_map = game.path_map
    if tank.x.position >= screen.width or tank.y.position >= screen.height then
      table.insert(game.hidden_tanks, tank)
      table.insert(to_remove, j)
    else
      tank.x.bound = screen.width
      tank.y.bound = screen.height
    end
  end
  for i, index in ipairs(to_remove) do
    table.remove(game.tanks, index)
  end
end
