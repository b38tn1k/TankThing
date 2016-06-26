require "events"
function love.load()
  -- Setup Screen/Window
  love.window.setTitle('UnUntitled')
  screen = {}
  screen.width, screen.height = 800, 600
  love.window.setMode(screen.width, screen.height, {resizable=true, minwidth=400, minheight=300})
  -- Setup Variables
  math.randomseed(os.time())
  time = 0
  -- Make Shader(s)
  myShader = love.graphics.newShader("brighterrgb.glsl")
  flasher = love.graphics.newShader("flasher.glsl")
  -- Make World
  occupancy_resolution = 5
  World = require("classes.world")
  world = World.create(screen.width, screen.height, occupancy_resolution)
  worldseed = world:newSeed()
  occupancy_grid = world:generate()
  world:makeCanvas(myShader)
  -- Make Projectiles
  projectiles = {}
  Projectile = require("classes.projectile")
  -- Make Tanks
  tanks = {}
  Tank = require("classes.tank")
  x_position = screen.width/2
  y_position = screen.height/2
  x_bound = screen.width
  y_bound = screen.height
  top_speed = 60
  projectile_speed = 600
  projectile_lifespan = 0.3
  img3_pth = "tank_selected.png"
  img1_pth = "blue_tank_base.png"
  img2_pth = "blue_tank_turrent.png"
  img4_pth = "blue_missile.png"
  tank1 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, img1_pth, img2_pth, img3_pth, img4_pth)
  tank1:init(1, 0.5, 0.3, 0.5)
  img1_pth = "green_tank_base.png"
  img2_pth = "green_tank_turrent.png"
  img4_pth = "green_missile.png"
  tank2 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, img1_pth, img2_pth, img3_pth, img4_pth)
  tank2:init(2, 0.5, 0.6, 0.5)
  img1_pth = "red_tank_base.png"
  img2_pth = "red_tank_turrent.png"
  img4_pth = "red_missile.png"
  tank3 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, img1_pth, img2_pth, img3_pth, img4_pth)
  tank3:init(3, 0.5, 0.5, 0.5)
  img1_pth = "black_tank_base.png"
  img2_pth = "black_tank_turrent.png"
  img4_pth = "black_missile.png"
  tank4 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, img1_pth, img2_pth, img3_pth, img4_pth)
  tank4:init(4, 0.7, 0.6, 0.2)
  table.insert(tanks, tank1)
  table.insert(tanks, tank2)
  table.insert(tanks, tank3)
  table.insert(tanks, tank4)
end

function love.update(dt)
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
    if projectile.x.position > screen.width or projectile.x.position < 0 or projectile.y.position > screen.height or projectile.y.position < 0 or projectile.age > projectile.life_span then
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

function love.draw()
    world:draw()
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
    love.graphics.reset()
end
