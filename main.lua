function love.load()
  math.randomseed(os.time())
  love.window.setTitle('UnUntitled')
  screen = {}
  screen.width, screen.height = 800, 600
  -- love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=400, minheight=300, borderless=true}) --pretty but hard to use
  love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=400, minheight=300})
  -- success = love.window.setFullscreen( true )
  World = require("classes.world")
  tank = require("classes.tank")
  projectile = require("classes.projectile")
  world = World.create(screen.width, screen.height)
  worldseed = world:newSeed()
  world:generateAndRender()
  tank.init(screen.width/2, screen.height/2, screen.width, screen.height, 400, 600, projectile, "blue_tank_base.png", "blue_tank_turrent.png", "blue_missile.png")
  time = 0

end

function love.update(dt)
  time = time + dt
  tank.userControl()
  tank.approachTarget(dt)
  tank.rotate(dt)
  tank.update(dt, 1)
end

function love.draw()
  world:draw()
  tank.draw()
end

function love.mousepressed(x, y, button, istouch)
  tank.setWaypoint(x, y)
end

function love.keyreleased(key)
  if key == " " then
    tank.fire_main_weapon()
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
  print(("Window resized to width: %d and height: %d."):format(w, h))
end
