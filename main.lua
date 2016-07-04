require "classes.events"
require "classes.path_finding"
function love.load()
  math.randomseed(os.time() * 1000)
  -- CLEAR OUT RANDOM BUFFER
  for i = 1, 100 do
    math.random()
  end
  -- GAME CONTROLER ALSO CONTAINS VARIABLES, ASSETS AND CONSTANTS
  game = require("classes.game")
  game.assets = require('classes.load_assets')
  -- WINDOW SETUP
  title = {'UnUntitled', 'I had something for this...', 'I LÖVE Lua', '༼ つ ◕_◕ ༽つ 💗 Tank', }
  love.window.setTitle(title[math.random(#title)])
  -- game.screen.width, game.screen.height = love.window.getDesktopDimensions(1)
  game.screen.width, game.screen.height = 500, 500
  love.window.setMode(game.screen.width, game.screen.height, {resizable=true, minwidth=500, minheight=500})
  -- SHADERS
  flasher = love.graphics.newShader("shaders/flasher.shader")
  -- IMPORT CLASSES
  -- MENU CLASS
  Menu = require("classes.menu")
  game.menu = Menu.create(game.screen.width, game.screen.height, game.assets)
  -- WORLD CLASS
  render_resolution = 5
  World = require("classes.world")
  -- CREATE A MAP FOR START SCREEN BACKGROUND
  game.world = World.create(game.screen.width, game.screen.height, game.path_resolution, render_resolution)
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
    -- UPDATE SHADERS
    flasher:send("time", game.time)
    -- UPDATE TANKS
    game.update_tanks(dt)
    -- UPDATE PROJECTILES
    game.update_projectiles(dt)
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
