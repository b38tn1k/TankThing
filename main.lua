function love.load()
  math.randomseed(os.time())
  love.window.setTitle('UnUntitled')
  World = require("classes.world")
  tank = require("classes.tank")
  projectile = require("classes.projectile")
  world = World.create()
  tank.init(world.window.width/2, world.window.height/2, world.window.width, world.window.height, 400, 600, projectile, "blue_tank_base.png", "blue_tank_turrent.png", "blue_missile.png")
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
  tank.debug_view()
end

function love.mousepressed(x, y, button, istouch)
  tank.setWaypoint(x, y)
end

function love.keyreleased(key)
  if key == " " then
    tank.fire_main_weapon()
  end
end
