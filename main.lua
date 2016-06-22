function love.load()
  math.randomseed(os.time())
  love.window.setTitle('UnUntitled')
  screen = {}
  screen.width, screen.height = 800, 600
  love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=400, minheight=300})
  World = require("classes.world")
  world = World.create(screen.width, screen.height)
  worldseed = world:newSeed()
  world:generateAndRender()
  Projectile = require("classes.projectile")
  Tank = require("classes.tank")
  time = 0
  projectiles = {}
  tanks = {}
  -- SETUP TANKS
  x_position = screen.width/2
  y_position = screen.height/2
  x_bound = screen.width
  y_bound = screen.height
  top_speed = 300
  projectile_speed = 600
  img1_pth = "blue_tank_base.png"
  img2_pth = "blue_tank_turrent.png"
  img3_pth = "blue_missile.png"
  tank = Tank.create(1, x_position, y_position, x_bound, y_bound, top_speed, projectile_speed, img1_pth, img2_pth, img3_pth)
  tank2 = Tank.create(2, x_position + 50, y_position + 50, x_bound, y_bound, top_speed, projectile_speed, img1_pth, img2_pth, img3_pth)
  table.insert(tanks, tank)
  table.insert(tanks, tank2)

end

function love.update(dt)
  time = time + dt
  tank:userControl()
  tank:approachTarget(dt)
  tank:rotate(dt)
  tank:update(dt, 1)
  for i, projectile in ipairs(projectiles) do
    -- Remove Projectiles that leave screen (TODO: fix magic numbers due to sprite)
    if projectile.x.position > screen.width or projectile.x.position < 0 or projectile.y.position > screen.height or projectile.y.position < 0 then
      table.remove(projectiles, i)
    else
      projectile:update(dt)
    end
    -- Check for Collisions between armed projectiles and tanks/entities
    for j, tank in ipairs(tanks) do
      if projectile.x.position >= tank.hitbox.x_min and projectile.x.position <= tank.hitbox.x_max then
        if projectile.y.position >= tank.hitbox.y_min and projectile.y.position <= tank.hitbox.y_max and tank.id ~= projectile.parent_id then
          table.remove(projectiles, i)
        end
      end
    end
  end
end

function love.draw()
  love.graphics.reset()
  world:draw()
  tank:drawLayer1()
  tank:debug_view()
  for i, projectile in ipairs(projectiles) do
    projectile:draw()
  end
  tank:drawLayer2()
  tank2:drawLayer1()
  tank2:drawLayer2()
end

function love.mousepressed(x, y, button, istouch)
  tank:setWaypoint(x, y)
end

function love.keyreleased(key)
  if key == " " then
    projectile = Projectile.create(tank:fire_main_weapon())
    table.insert(projectiles, projectile)
  end
  if key == "r" then
    worldseed = world:newSeed()
    world:generateAndRender()
  end
  if key == "escape" then
    love.event.quit( )
  end
end

function love.resize(w, h)
  screen.width, screen.height = w, h
  world = World.create(screen.width, screen.height)
  world.seed = worldseed
  world:generateAndRender()
  tank.x.bound = screen.width
  tank.y.bound = screen.height
  print(("Window resized to width: %d and height: %d."):format(w, h))
end
