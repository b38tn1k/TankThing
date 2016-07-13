function proto_team(size)
  local new_team = {}
  new_team.size = size
  return new_team
end

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
game.draw_blank_screen = false
game.teams = {}
game.number_of_teams = 4
game.screen = {}
game.screen.width = 0
game.screen.height = 0
game.player = {}
game.player.team = 1
game.team_sizes = {1, 2, 3, 4}

function new()
  game.teams = {}
  game.team_sizes = game.menu.team_count
  for i = 1, game.number_of_teams do
    table.insert(game.teams, proto_team(game.team_sizes[i]))
  end
  game.screen.width, game.screen.height = lg.getDimensions()
  game.draw_blank_screen = true
  game.worldseed = game.world:newSeed()
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  game.tanks = {}
  game.hidden_tanks = {}
  local id = 1
  for i = 1, game.number_of_teams do
    local random_area = math.random((#game.path_map / game.number_of_teams) * i) -- find a basic area
    local neighbours = find_more_neighbours(game.path_map[random_area], game.path_map, 2, 2) -- generate surrounding potential spawn points
    for j = 1, game.teams[i].size do
      local random_position = math.random(#neighbours)
      local random_node = neighbours[random_position]
      tank = Tank.create(game.screen.width, game.screen.height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.path_resolution, game.assets.small_tanks[i])
      if random_node ~= nil then
        tank:init(id, i, random_node, math.random())
        id = id + 1
      else
        -- try again
        new()
      end
      table.remove(neighbours, random_position)
      for k = 1, game.teams[i].size do -- remove potential surrounding spawn points
        table.remove(neighbours, random_position + k)
        table.remove(neighbours, random_position - k)
      end
      table.insert(game.tanks, tank)
    end
  end
  game.team_sizes = game.menu.team_count
  game.pause = false
  game.draw_blank_screen = false
end
game.new = new

function resize()
  game.screen.width, game.screen.height = lg.getDimensions()
  game.draw_blank_screen = true
  -- REBUILD WORLD, MENU
  game.world = World.create(game.screen.width, game.screen.height, game.path_resolution, render_resolution)
  game.world.seed = game.worldseed -- naming sort of sucks here :-P
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  game.team_sizes = game.menu.team_count
  game.menu = Menu.create(game.screen.width, game.screen.height, game.assets)
  game.menu.team_count = game.team_sizes
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
  game.draw_blank_screen = false
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
      game.make_tank_shoot(tank)
    end
  end
end
game.fire_active_tank = fire_active_tank

function make_tank_shoot(tank)
  local can_fire = true
  for _, proj in ipairs(game.projectiles) do
    if proj.parent_id == tank.id then
      can_fire = false
    end
  end
  if can_fire == true then
    local data = tank:fire_main_weapon()
    if next(data) ~= nil then
      projectile = Projectile.create(data)
      table.insert(game.projectiles, projectile)
    end
  end
end
game.make_tank_shoot = make_tank_shoot

function select_tank(x, y)
  local newly_selected = false
  for j, tank in ipairs(game.tanks) do
    if tank:check_for_collision(x, y) and tank.team == game.player.team then
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
