require "classes.events" require "classes.path_finding" require "classes.targetting"
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
  -- PLAYER LASSO CLASS
  game.lasso_creator = require("classes.lasso")
  -- WORLD CLASS
  World = require("classes.world")
  -- CREATE A MAP FOR START SCREEN BACKGROUND
  game.world = World.create(game.world_width, game.world_height, game.screen.width, game.screen.height, game.resolution)
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
  -- FACTORY CLASS
  game.factories = {}
  Factory = require("classes.factory")
  -- SET SOME TANK VARIABLES
  -- top_speed = 30
  top_speed = 60
  projectile_speed = 200
  projectile_lifespan = 1 -- SECONDS
  Explosion = require("classes.explosion")
  game.explosions = Explosion.create(1, 40, 5)
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
    -- UPDATE WORLD TO SCREEN POSITION
    game.world:update()
    -- UPDATE LASSO IF IT EXISTS
    if game.lasso ~= nil then
      game.lasso:update(love.mouse.getPosition())
    end
    -- UPDATE SHADERS
    local a_tank_is_selected = false
    for j, tank in ipairs(game.tanks) do
      if tank.selected then
        a_tank_is_selected = true
        spotlight:send("radius", 50)
        -- spotlight:send("xy", tank.x.position + game.world.offset.x, lg.getHeight() - tank.y.position - game.world.offset.y)
        spotlight:send("xy", tank.x.position + game.world.offset.x, tank.y.position + game.world.offset.y)
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
    -- DRAW FACTORIES
    for j, factory in ipairs(game.factories) do
      factory:draw(game.world.offset)
    end
    -- DRAW TANK BASE LAYERS
    for j, tank in ipairs(game.tanks) do
      tank:drawLayer1(game.world.offset)
    end
    -- DRAW PROJECTILES
    for i, projectile in ipairs(game.projectiles) do
      projectile:draw(game.world.offset)
    end
    -- DRAW TANK TURRENTS
    for j, tank in ipairs(game.tanks) do
      tank:drawLayer2(game.world.offset)
    end
    -- DRAW LASSO IF IT EXISTS
    if game.lasso ~= nil then
      game.lasso:draw()
    end
    -- DEBUG VIEW ON TOP
    if game.debug == true then
      game.world:drawDebug()
      for _, tank in ipairs(game.tanks) do
        tank:drawPath()
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
  -- game.explosions:draw(0, 0)
end
