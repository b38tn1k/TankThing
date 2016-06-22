function love.load()
  math.randomseed(os.time())
  love.window.setTitle('UnUntitled')
  screen = {}
  screen.width, screen.height = 800, 600
  love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=400, minheight=300})
  World = require("classes.world")
  Tank = require("classes.tank")
  Projectile = require("classes.projectile")
  world = World.create(screen.width, screen.height)
  worldseed = world:newSeed()
  world:generateAndRender()
  -- SETUP TANK
  x_position = screen.width/2
  y_position = screen.height/2
  x_bound = screen.width
  y_bound = screen.height
  top_speed = 400
  projectile_speed = 600
  projectiles = {}
  img1_pth = "blue_tank_base.png"
  img2_pth = "blue_tank_turrent.png"
  img3_pth = "blue_missile.png"
  -- why does it skip first arguement? TODO
  tank = Tank.create(0, x_position, y_position, x_bound, y_bound, top_speed, projectile_speed, img1_pth, img2_pth, img3_pth)
  time = 0

end

function love.update(dt)
  time = time + dt
  tank:userControl()
  tank:approachTarget(dt)
  tank:rotate(dt)
  tank:update(dt, 1)
  for i, projectile in ipairs(projectiles) do
    if projectile.x.position > screen.width or projectile.x.position < 0 or projectile.y.position > screen.height or projectile.y.position < 0 then
      table.remove(projectiles, i)
    else
      projectile:update(dt)
    end
  end
end

function love.draw()
  -- love.graphics.reset()
  -- world:draw()
  tank:draw()
  tank:debug_view()
  for i, projectile in ipairs(projectiles) do
    projectile:draw()
  end
end

function love.mousepressed(x, y, button, istouch)
  tank:setWaypoint(x, y)
end

function love.keyreleased(key)
  if key == " " then
    data = tank:fire_main_weapon()    -- THIS IS A BIT GROSS TODO
    projectile = Projectile.create(data[1], data[2], data[3], data[4], data[5])
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
