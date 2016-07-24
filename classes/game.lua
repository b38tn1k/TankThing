function proto_team(size)
  local new_team = {}
  new_team.size = size
  return new_team
end

function new_command(x, y, id)
  local command = {}
  command.x = x
  command.y = y
  command.id = id
  return command
end

local game = {}
game.tanks = {}
game.hidden_tanks = {}
game.projectiles = {}
game.world = {}
game.resolution = 10
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
game.team_sizes = {5, 5, 5, 5}
game.world_width = 3000
game.world_height = 3000
game.sequenced_commands = {}

function new()
  game.teams = {}
  game.team_sizes = game.menu.team_sizes
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
    local neighbours = findMoreNeighbours(game.path_map[random_area], game.path_map, 2, 2) -- generate surrounding potential spawn points
    for j = 1, game.teams[i].size do
      local random_position = math.random(#neighbours)
      local random_node = neighbours[random_position]
      tank = Tank.create(game.world_width, game.world_height, top_speed, projectile_speed, projectile_lifespan, game.path_map, game.resolution, game.assets.small_tanks[i])
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
  game.team_sizes = game.menu.team_sizes
  game.pause = false
  game.draw_blank_screen = false
end
game.new = new

function resize()
  game.screen.width, game.screen.height = lg.getDimensions()
  -- REBUILD WORLD, MENU
  game.world = World.create(game.world_width, game.world_height, game.screen.width, game.screen.height, game.resolution)
  game.world.seed = game.worldseed -- naming sort of sucks here :-P
  game.path_map = game.world:generate()
  game.world:makeCanvas(1)
  game.team_sizes = game.menu.team_sizes
  game.menu = Menu.create(game.screen.width, game.screen.height, game.assets)
  game.menu.team_sizes = game.team_sizes
end
game.resize = resize

function updateTanks(dt)
  for j, tank in ipairs(game.tanks) do
    tank:update(dt, 1)
  end
end
game.updateTanks = updateTanks

function updateProjectiles(dt)
  for i, projectile in ipairs(game.projectiles) do
    if projectile:removable(game.screen) then
      table.remove(game.projectiles, i)
    else
      projectile:update(dt)
    end
    -- CHECK FOR TANK/PROJECTILE COLLISIONS
    for j, tank in ipairs(game.tanks) do
      if tank:check4collision(projectile.x.position, projectile.y.position) == true and tank.id ~= projectile.parent_id then
        table.remove(game.projectiles, i)
        table.remove(game.tanks, j)
      end
    end
  end
end
game.updateProjectiles = updateProjectiles

function fireActiveTank()
  for j, tank in ipairs(game.tanks) do
    if tank.selected == true then
      game.makeTankShoot(tank)
    end
  end
end
game.fireActiveTank = fireActiveTank

function makeTankShoot(tank)
  local can_fire = true
  for _, proj in ipairs(game.projectiles) do
    if proj.parent_id == tank.id then
      can_fire = false
    end
  end
  if can_fire == true then
    local data = tank:fireMainWeapon()
    if next(data) ~= nil then
      projectile = Projectile.create(data)
      table.insert(game.projectiles, projectile)
    end
  end
end
game.makeTankShoot = makeTankShoot

function deselectTanks()
  for _, tank in ipairs(game.tanks) do
    tank.selected = false
  end
end
game.deselectTanks = deselectTanks

function selectTank(x, y)
  x = x - game.world.offset.x
  y = y - game.world.offset.y
  local newly_selected = false
  for j, tank in ipairs(game.tanks) do
    if tank:check4collision(x, y) and tank.team == game.player.team then
      for j, other_tank in ipairs(game.tanks) do
        other_tank.selected = false
      end
      tank.selected = true
      newly_selected = true
    end
  end
  for j, tank in ipairs(game.tanks) do
    if tank.selected == true and newly_selected == false then
      if love.keyboard.isDown('lshift') then 
        table.insert(game.sequenced_commands, new_command(x, y, tank.id))
      else
        tank:addWaypoint(x, y)
      end
    end
  end
end
game.selectTank = selectTank

function playCommands()
  for _, command in ipairs(game.sequenced_commands) do
    for _, tank in ipairs(game.tanks) do 
      if tank.id == command.id then
        tank:addWaypoint(command.x, command.y)
      end
    end
  end
  game.sequenced_commands = {}
end
game.playCommands = playCommands

return game
