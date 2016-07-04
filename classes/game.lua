local game = {}

game.tanks = {}
game.hidden_tanks = {}
game.projectiles = {}
game.world = {}
game.path_resolution = 10
game.path_map = {}
game.menu = {}
game.time = 0
game.pause = true
game.debug = false
game.assets = {}
game.screen = {}

function new()
  game.worldseed = game.world:newSeed()
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  game.tanks = {}
  game.hidden_tanks = {}
  tank1 = Tank.create(game.screen.width, game.screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.blue)
  tank2 = Tank.create(game.screen.width, game.screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.red)
  tank3 = Tank.create(game.screen.width, game.screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.black)
  tank4 = Tank.create(game.screen.width, game.screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks.green)
  random_node = math.random( #game.path_map)
  tank1:init(1, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
  random_node = math.random( #game.path_map)
  tank2:init(2, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
  random_node = math.random( #game.path_map)
  tank3:init(3, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
  random_node = math.random( #game.path_map)
  tank4:init(4, game.path_map[random_node].x * game.path_resolution, game.path_map[random_node].y * game.path_resolution, math.random())
  table.insert(game.tanks, tank1)
  table.insert(game.tanks, tank2)
  table.insert(game.tanks, tank3)
  table.insert(game.tanks, tank4)
  game.pause = false
end
game.new = new

function resize()
  -- REBUILD WORLD, MENU
  game.world = World.create(game.screen.width, game.screen.height, game.path_resolution, render_resolution)
  game.world.seed = game.worldseed -- naming sort of sucks here :-P
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  game.menu = Menu.create(game.screen.width, game.screen.height, game.assets)
  -- HIDE OR SHOW TANKS
  to_remove = {}
  for i, tank in ipairs(game.hidden_tanks) do
    tank.path_map = game.path_map
    if tank.x.position < game.screen.width or tank.y.position < game.screen.height then
      table.insert(game.tanks, tank)
      table.insert(to_remove, i)
    end
  end
  for i, index in ipairs(to_remove) do
    table.remove(game.hidden_tanks, index)
  end
  to_remove = {}
  for j, tank in ipairs(game.tanks) do
    tank.path_map = game.path_map
    if tank.x.position >= game.screen.width or tank.y.position >= game.screen.height then
      table.insert(game.hidden_tanks, tank)
      table.insert(to_remove, j)
    else
      tank.x.bound = game.screen.width
      tank.y.bound = game.screen.height
    end
  end
  for i, index in ipairs(to_remove) do
    table.remove(game.tanks, index)
  end
end
game.resize = resize

function update_tanks(dt)
  for j, tank in ipairs(game.tanks) do
    tank:update(dt, 1)
  end
end
game.update_tanks = update_tanks

function update_projectiles(dt)
  for i, projectile in ipairs(game.projectiles) do
    if projectile:removable(game.screen) then
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
game.update_projectiles = update_projectiles

function fire_active_tank()
  for j, tank in ipairs(game.tanks) do
    if tank.selected == true then
      projectile = Projectile.create(tank:fire_main_weapon())
      table.insert(game.projectiles, projectile)
    end
  end
end
game.fire_active_tank = fire_active_tank

function select_tank(x, y)
  local newly_selected = false
  for j, tank in ipairs(game.tanks) do
    if tank:check_for_collision(x, y) then
      for j, other_tank in ipairs(game.tanks) do
        other_tank.selected = false
      end
      tank.selected = true
      newly_selected = true
    end
  end
  for j, tank in ipairs(game.tanks) do
    if tank.selected == true and newly_selected == false then
      tank:addWaypoint(x, y)
    end
  end
end
game.select_tank = select_tank

return game
