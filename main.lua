require "classes.events"
require "classes.path_finding"
require "classes.targetting"
function love.load()
  math.randomseed(os.time() * 1000)
  -- CLEAR OUT RANDOM BUFFER
  for i = 1, 100 do
    math.random()
  end
  -- some aliases
  lg = love.graphics
  -- GAME CONTROLER ALSO CONTAINS VARIABLES, ASSETS AND CONSTANTS
  game = require("classes.game")
  game.assets = require('classes.load_assets')
  -- WINDOW SETUP
  title = {'UnUntitled', 'I had something for this...', 'I LÖVE Lua', '༼ つ ◕_◕ ༽つ 💗 Tank', }
  love.window.setTitle(title[math.random(#title)])
  love.window.setMode(640, 360, {resizable=true, minwidth=500, minheight=500})
  game.screen.width, game.screen.height = lg.getDimensions()
  -- SHADERS
  flasher = lg.newShader("shaders/flasher.shader")
  spotlight = lg.newShader("shaders/spotlight.shader")
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
  -- top_speed = 30
  top_speed = 60
  projectile_speed = 200
  projectile_lifespan = 0.5 -- SECONDS
end

function love.update(dt)
  -- PAUSE MENU
  if game.pause == true then
    game.menu:update()
    for j, tank in ipairs(game.tanks) do
      tank.selected = false
    end
  else
    game.time = game.time + dt
    -- UPDATE SHADERS
    local a_tank_is_selected = false
    for j, tank in ipairs(game.tanks) do
      if tank.selected then
        a_tank_is_selected = true
        spotlight:send("radius", 50)
        spotlight:send("xy", tank.x.position, lg.getHeight() - tank.y.position)
      end
    end
    if a_tank_is_selected == false then
      spotlight:send("radius", 0)
    end
    -- UPDATE TANKS
    game.updateTanks(dt)
    targetting(game.tanks, game.projectiles)
    -- UPDATE PROJECTILES
    game.updateProjectiles(dt)
  end
end

function love.draw()
  if game.draw_blank_screen == false then
    -- SPOTLIGHT SHADER
    lg.setShader(spotlight)
    -- DRAW WORLD
    game.world:draw()
    -- DRAW TANK BASE LAYERS
    for j, tank in ipairs(game.tanks) do
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
    -- DEBUG VIEW ON TOP
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
    end
    lg.setShader()
    lg.reset()
  else
    lg.clear()
  end
end
