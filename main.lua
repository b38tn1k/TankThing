require "classes.events"
require "classes.path_finding"
function love.load()
  math.randomseed(os.time() * 1000)
  -- CLEAR OUT RANDOM BUFFER
  for i = 1, 100 do
    math.random()
  end
  -- WINDOW SETUP
  title = {'UnUntitled', 'I had something for this...', 'I LÖVE Lua', '༼ つ ◕_◕ ༽つ 💗 Tank', }
  love.window.setTitle(title[math.random(#title)])
  screen = {}
  -- screen.width, screen.height = love.window.getDesktopDimensions(1)
  screen.width, screen.height = 500, 500
  love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=500, minheight=500})
  -- GAME CONTROLER ALSO CONTAINS VARIABLES, ASSETS AND CONSTANTS
  game = require("classes.game")
  game.assets = require('classes.load_assets')
  -- SHADERS
  flasher = love.graphics.newShader("shaders/flasher.shader")
  -- IMPORT CLASSES
  -- MENU CLASS
  Menu = require("classes.menu")
  game.menu = Menu.create(screen.width, screen.height, game.assets)
  -- WORLD CLASS
  render_resolution = 5
  World = require("classes.world")
  -- CREATE A MAP FOR START SCREEN BACKGROUND
  game.world = World.create(screen.width, screen.height, game.path_resolution, render_resolution)
  game.worldseed = game.world:newSeed()
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  -- PROJECTILES CLASS
  game.projectiles = {}
  Projectile = require("classes.projectile")
  -- TANKS CLASS
  game.tanks = {}
  game.hidden_tanks = {}
  Tank = require("classes.tank")
  -- SET SOME TANK VARIABLES
  top_speed = 30
  projectile_speed = 200
  projectile_lifespan = 1 -- SECONDS
end

function love.update(dt)
  -- PAUSE MENU
  if game.pause == true then
    time = 0
  else
    game.time = game.time + dt
    flasher:send("time", game.time)
    -- UPDATE TANKS
    for j, tank in ipairs(game.tanks) do
      tank:update(dt, 1)
    end
    -- UPDATE PROJECTILES
    for i, projectile in ipairs(game.projectiles) do
      if projectile:removable() then
        table.remove(game.projectiles, i)
      else
        projectile:update(dt)
      end
      -- CHECK FOR TANK/PROJECTILE COLLISIONS
      for j, tank in ipairs(game.tanks) do
        if tank:check_for_collision(projectile.x.position, projectile.y.position) == true and tank.id ~= projectile.parent_id then
          table.remove(game.projectiles, i)
          table.remove(game.tanks, j)
        end
      end
    end
  end
end

function love.draw()
  game.world:draw()
  -- DEBUG OPTIONS
  if game.debug == true then
    game.world:drawDebug()
    for _, tank in ipairs(game.tanks) do
      tank:draw_path()
      if tank.selected then
        tank:drawDebug()
      end
    end
  end
  -- PAUSE GAME MENU
  if game.pause == true then
    game.menu:draw()
  else
    -- DRAW TANK BASE LAYERS
    for j, tank in ipairs(game.tanks) do
      if tank.selected then
        tank:drawHalo(flasher)
      end
      tank:drawLayer1()
    end
    -- DRAW PROJECTILES
    for i, projectile in ipairs(game.projectiles) do
      projectile:draw()
    end
    -- DRAW TANK TURRENTS
    for j, tank in ipairs(game.tanks) do
      tank:drawLayer2()
    end
  end
  love.graphics.reset()
end
