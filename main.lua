require "events"
function love.load()
  -- Setup Screen/Window
  love.window.setTitle('UnUntitled')
  screen = {}
  -- screen.width, screen.height = love.window.getDesktopDimensions(1)
  screen.width, screen.height = 500, 500
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
  hidden_tanks = {}
  Tank = require("classes.tank")
  x_position = screen.width/2
  y_position = screen.height/2
  x_bound = screen.width
  y_bound = screen.height
  top_speed = 30
  projectile_speed = 200
  projectile_lifespan = 1
  img3_pth = "small_tank_selected.png"
  img1_pth = "small_blue_tank_base.png"
  img2_pth = "small_blue_tank_turrent.png"
  img4_pth = "small_blue_missile.png"
  tank1 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, occupancy_grid, occupancy_resolution, img1_pth, img2_pth, img3_pth, img4_pth)
  img1_pth = "small_green_tank_base.png"
  img2_pth = "small_green_tank_turrent.png"
  img4_pth = "small_green_missile.png"
  tank2 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, occupancy_grid, occupancy_resolution, img1_pth, img2_pth, img3_pth, img4_pth)
  img1_pth = "small_red_tank_base.png"
  img2_pth = "small_red_tank_turrent.png"
  img4_pth = "small_red_missile.png"
  tank3 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, occupancy_grid, occupancy_resolution, img1_pth, img2_pth, img3_pth, img4_pth)
  img1_pth = "small_black_tank_base.png"
  img2_pth = "small_black_tank_turrent.png"
  img4_pth = "small_black_missile.png"
  tank4 = Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, occupancy_grid, occupancy_resolution, img1_pth, img2_pth, img3_pth, img4_pth)
  random_node = math.random( #occupancy_grid)
  tank1:init(1, occupancy_grid[random_node].x * occupancy_resolution, occupancy_grid[random_node].y * occupancy_resolution, 0.5)
  random_node = math.random( #occupancy_grid)
  tank2:init(2, occupancy_grid[random_node].x * occupancy_resolution, occupancy_grid[random_node].y * occupancy_resolution, 0.5)
  random_node = math.random( #occupancy_grid)
  tank3:init(3, occupancy_grid[random_node].x * occupancy_resolution, occupancy_grid[random_node].y * occupancy_resolution, 0.5)
  random_node = math.random( #occupancy_grid)
  tank4:init(4, occupancy_grid[random_node].x * occupancy_resolution, occupancy_grid[random_node].y * occupancy_resolution, 0.5)
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
