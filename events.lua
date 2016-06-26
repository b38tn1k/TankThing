function love.mousepressed(x, y, button, istouch)
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

function love.keyreleased(key)
  if key == " " then
    for j, tank in ipairs(tanks) do
      if tank.selected == true then
        projectile = Projectile.create(tank:fire_main_weapon())
        table.insert(projectiles, projectile)
      end
    end
  end
  if key == "r" then
    worldseed = world:newSeed()
    occupancy_grid = world:generate()
    world:makeCanvas(myShader)
  end
  if key == "escape" then
    love.event.quit( )
  end
end

function love.resize(w, h)
  screen.width, screen.height = w, h
  world = World.create(screen.width, screen.height, occupancy_resolution)
  world.seed = worldseed
  world:generate(myShader)
  world:makeCanvas(myShader)
  to_remove = {}
  for i, tank in ipairs(hidden_tanks) do
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
