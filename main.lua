function love.load()
  math.randomseed(os.time())
  love.window.setTitle('UnUntitled')
  world = require("classes.world")
  tank = require("classes.tank")
  projectile = require("classes.projectile")
  world.init()
  tank.init(world.window.width/2, world.window.height/2, world.window.width, world.window.height, 400, 600, projectile, "blue_tank_base.png", "blue_tank_turrent.png", "blue_missile.png")
  wasd = true
  drift = false
  click = false
  follow = false
end

function love.update(dt)
  world.time = world.time + dt
  tank.userControl()
  tank.approachTarget(dt)
  tank.rotate(dt)
  tank.update(dt, 1)
end

function love.draw()
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
