require "events"
function love.load()
  math.randomseed(os.time() * 1000)
  for i = 1, 100 do   -- clear out start of random buffer
    math.random()
  end
  -- Setup Screen/Window
  title = {'UnUntitled', 'I had something for this...', 'I LÖVE Lua', '༼ つ ◕_◕ ༽つ I 💗 Tank', }
  love.window.setTitle(title[math.random(#title)])
  screen = {}
  -- screen.width, screen.height = love.window.getDesktopDimensions(1)
  screen.width, screen.height = 500, 500
  love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=500, minheight=500})
  -- Setup Variables, Assets
  time = 0
  pause = true
  debug = false
  local images = require('image_paths')
  tank_image_paths = images[1]
  small_tank_image_paths = images[2]
  -- Make Shader(s)
  myShader = love.graphics.newShader("brighterrgb.glsl")
  flasher = love.graphics.newShader("flasher.glsl")
  -- Make Menu
  Menu = require("classes.menu")
  menu = Menu.create(screen.width, screen.height, tank_image_paths, "logo.png")
  -- Make World
  path_resolution = 10
  render_resolution = 5
  World = require("classes.world")
  world = World.create(screen.width, screen.height, path_resolution, render_resolution)
  worldseed = world:newSeed()
  path_map = world:generate()
  world:makeCanvas(myShader)
  -- Make Projectiles
  projectiles = {}
  Projectile = require("classes.projectile")
  -- Make Tanks
  tanks = {}
  hidden_tanks = {}
  Tank = require("classes.tank")
  top_speed = 30
  projectile_speed = 200
  projectile_lifespan = 1
end

function love.update(dt)
  if pause == true then -- DRAW MENU
    time = 0
  else
    time = time + dt
    flasher:send("time", time)
    for j, tank in ipairs(tanks) do
      tank:userControl()
      tank:rotate_turrent()
      tank:approachTarget(dt)
      tank:update(dt, 1)
    end
    for i, projectile in ipairs(projectiles) do
      -- Remove Projectiles that leave screen or are too old
      if projectile:removable() then 
        table.remove(projectiles, i)
      else
        projectile:update(dt)
      end
      -- Check for Collisions between armed projectiles and tanks/entities
      for j, tank in ipairs(tanks) do
        if tank:check_for_collision(projectile.x.position, projectile.y.position) == true and tank.id ~= projectile.parent_id then
          table.remove(projectiles, i)
          table.remove(tanks, j)
        end
      end
    end
  end
end

function love.draw()
  world:draw()
  if debug == true then
    world:drawDebug()
    for _, tank in ipairs(tanks) do
      tank:draw_path()
      if tank.selected then
        tank:drawDebug()
      end
    end
  end

  if pause == true then -- DRAW MENU
    menu:draw()
  else -- DRAW GAME
    for j, tank in ipairs(tanks) do
      if tank.selected then
        tank:drawHalo(flasher)
      end
      tank:drawLayer1()
    end
    for i, projectile in ipairs(projectiles) do
      projectile:draw()
    end
    for j, tank in ipairs(tanks) do
      tank:drawLayer2()
    end
  end
  love.graphics.reset()
end
