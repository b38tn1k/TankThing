-- TANK Class
local Tank = {}
Tank.__index = Tank

-- SET UP THE TANK BOUNDARIES
function Tank.create(x_bound, y_bound, top_speed, projectile_speed, projectile_lifespan, path_map, path_map_res, imgs)
  -- CONSTANTS AND VARIABLES
  local t = {}
  setmetatable( t, Tank )
  t.selected = false
  t.top_speed = 400
  t.vel_gain = 0.12
  t.rot_gain = 0.12
  t.acceptable_lin_error = 0.01
  t.acceptable_rad_error = math.rad(45)
  t.autonomous = true
  t.speed = 0
  t.projectile = {}
  t.x = {}
  t.y = {}
  t.rotation = {}
  t.sprite = {}
  t.sprite.layer1 = {}
  t.sprite.layer2 = {}
  t.sprite.selected = {}
  t.hitbox = {}
  t.id = 0
  t.x.position = 0
  t.y.position = 0
  t.x.bound = x_bound
  t.y.bound = y_bound
  t.x.path = {}
  t.y.path = {}
  t.path_length = 1
  t.path_index = 1
  t.path_map = path_map
  t.path_map_resolution = path_map_res
  t.top_speed = top_speed
  t.projectile.speed = projectile_speed
  t.projectile.lifespan = projectile_lifespan
  t.sprite.layer1.img = love.graphics.newImage(imgs[2])
  t.sprite.layer2.img = love.graphics.newImage(imgs[3])
  t.sprite.selected.img = love.graphics.newImage(imgs[1])
  t.projectile.img_path = imgs[4]
  t.x.target = 0
  t.x.speed = 0
  t.x.velocity = 0
  t.x.image_offset = 0
  t.y.target = 0
  t.y.velocity = 0
  t.y.speed = 0
  t.y.image_offset = 0
  t.rotation.base = 0
  t.rotation.base_target = 0
  t.rotation.turrent = 0
  t.rotation.turrent_target = 0
  t.sprite.layer1.width = t.sprite.layer1.img:getWidth()
  t.sprite.layer1.height = t.sprite.layer1.img:getHeight()
  t.sprite.layer2.width = t.sprite.layer2.img:getWidth()
  t.sprite.layer2.height = t.sprite.layer2.img:getHeight()
  t.sprite.selected.width = t.sprite.selected.img:getWidth()
  t.sprite.selected.height = t.sprite.selected.img:getHeight()
  t.hitbox.x_max = 0
  t.hitbox.y_max = 0
  t.hitbox.x_min = 0
  t.hitbox.y_min = 0
  t.hitbox.offset = math.min(t.sprite.layer1.width/2, t.sprite.layer1.height/2 )
  return t
end

function Tank:init(id, x, y, theta)
  self.id = id
  self.x.position = x
  self.y.position = y
  table.insert(self.x.path, self.x.position)
  table.insert(self.y.path, self.y.position)
  self.rotation.base = theta
  self.rotation.base_target = theta
end

function Tank:drawDebug()
  position_string = "POS: ".. (string.format("%.2f", self.x.position)) .. ",\t" .. (string.format("%.2f", self.y.position))
  target_string = "TAR: ".. (string.format("%.2f", self.x.target)) .. ",\t" .. (string.format("%.2f", self.y.target))
  velocity_string = "VEL: ".. (string.format("%.2f", self.x.velocity)) .. ",\t" .. (string.format("%.2f", self.y.velocity))
  orientation_string = "ORI: ".. string.format("%.2f", self.rotation.base) .. "\tTAR: " .. string.format("%.2f", self.rotation.base_target)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.setFont(love.graphics.newFont(15))
  love.graphics.printf(position_string,10, self.y.bound - 64, 500, 'left')
  love.graphics.printf(target_string, 10, self.y.bound - 48, 500, 'left')
  love.graphics.printf(velocity_string, 10, self.y.bound - 32, 500, 'left')
  love.graphics.printf(orientation_string, 10, self.y.bound - 16, 500, 'left')
  -- HIT BOX
  love.graphics.rectangle("fill", self.hitbox.x_max, self.hitbox.y_min, 2, 2)
  love.graphics.rectangle("fill", self.hitbox.x_min, self.hitbox.y_max, 2, 2)
  love.graphics.rectangle("fill", self.hitbox.x_min, self.hitbox.y_min, 2, 2)
  love.graphics.rectangle("fill", self.hitbox.x_max, self.hitbox.y_max, 2, 2)
  -- HIT BOX
  love.graphics.reset()
end

-- DRAW THE TANK
function Tank:drawLayer1(shader)
  love.graphics.setShader(shader)
  love.graphics.draw(self.sprite.layer1.img, self.x.position, self.y.position, self.rotation.base, 1, 1, self.sprite.layer1.width/2, self.sprite.layer1.height/2)
  love.graphics.setShader()
end

function Tank:drawHalo(shader)
  love.graphics.setShader(shader)
  love.graphics.draw(self.sprite.selected.img, self.x.position, self.y.position, self.rotation.base, 1, 1, self.sprite.selected.width/2, self.sprite.selected.height/2)
  love.graphics.setShader()
end

function Tank:drawLayer2(shader)
  love.graphics.setShader(shader)
  love.graphics.draw(self.sprite.layer2.img, self.x.position, self.y.position, self.rotation.base + self.rotation.turrent, 1, 1, self.sprite.layer2.width/2, self.sprite.layer2.height/2)
  love.graphics.setShader()
end

-- ROTATE UPPER LAYER
function Tank:rotate_turrent()
  if self.selected == true then
    if self.rotation.turrent_target > math.rad(110) then
      self.rotation.turrent_target = math.rad(100)
    elseif self.rotation.turrent_target < 0 - math.rad(110) then
      self.rotation.turrent_target = 0 - math.rad(100)
    end
    if love.keyboard.isDown("lshift") then
      self.rotation.turrent_target  = 0
    end
    if love.keyboard.isDown("q") then
      self.rotation.turrent_target = self.rotation.turrent_target - 0.1
    end
    if love.keyboard.isDown("e") then
      self.rotation.turrent_target = self.rotation.turrent_target + 0.1
    end
  end
end

-- DAMPEN CHANGES IN VELOCITY, POSITION, ETC
function Tank:controlDampener(value, target, factor)
  new_value = value
  error = target - value
  if math.abs(error) > self.acceptable_lin_error then
    new_value = value + error * factor
  end
  return new_value
end

-- UPDATE VELOCITIES
function Tank:update_velocities()
  self.y.velocity = self.speed * math.sin(self.rotation.base + math.rad(90))
  self.x.velocity = self.speed * math.cos(self.rotation.base + math.rad(90))
end

-- TURN LEFT
function Tank:turn_left()
  self.rotation.base_target = self.rotation.base_target - 0.05
  self:update_velocities()
end

-- TURN RIGHT
function Tank:turn_right()
  self.rotation.base_target = self.rotation.base_target + 0.05
  self:update_velocities()
end

-- GO FORWARD
function Tank:forwards()
  self.speed = self:controlDampener(self.speed, 0 - self.top_speed, self.vel_gain)
  self:update_velocities()
end

-- GO BACKWARDS
function Tank:backwards()
  self.speed = self:controlDampener(self.speed, self.top_speed, self.vel_gain)
  self:update_velocities()
end

-- STOP
function Tank:slow_to_stop()
  self.speed = self:controlDampener(self.speed, 0, self.vel_gain)
  self:update_velocities()
end

function Tank:check_for_collision(x, y)
  collision = false
  if x ~= nil and y ~= nil then
    if x >= self.hitbox.x_min and x <= self.hitbox.x_max then
      if y >= self.hitbox.y_min and y <= self.hitbox.y_max then
        collision = true
      end
    end
  end
  return collision
end

function Tank:fire_main_weapon()
  data = {self.id, self.projectile.speed, self.projectile.lifespan, self.projectile.img_path, self.x.position, self.y.position, (self.rotation.turrent + self.rotation.base), self.x.bound, self.y.bound, self.sprite.layer2.height*2}
  return data
end

-- RETURN CLOSEST VALUE TO ZERO
function Tank:closestToZero(x, y)
  new_value = math.min(math.abs(x), math.abs(y))
  if x < 0 and y < 0 then
    new_value = new_value * -1
  end
  return new_value
end

-- EXCITING INERTIAL WASD CONTROL
function Tank:userControl()
  if self.selected == true then
    if love.keyboard.isDown("left", "a", "right", "d", "up", "w", "down", "s") then
      self.autonomous = false
      self.y.target = self.y.position
      self.x.target = self.x.position
    end
    if love.keyboard.isDown("left", "a") then
      self:turn_left()
    elseif love.keyboard.isDown("right", "d") then
      self:turn_right()
    end
    if love.keyboard.isDown("up", "w") then
      self:forwards()
    elseif love.keyboard.isDown("down", "s") then
      self:backwards()
    else
      self:slow_to_stop()
    end
  else
    self:slow_to_stop()
  end
end

-- SET UP AUTO TARGET FROM MOUSE CLICK OR SOMETHING. BEWARE: TRIG IS HACKY
function Tank:setTarget(x, y)
  prior_rotations = math.rad(360)*(math.floor((self.rotation.base + math.rad(180))/math.rad(360)))
  rotation = 0
  self.autonomous = true
  self.y.target = y
  self.x.target = x
  rise = self.y.target - self.y.position
  run = self.x.target - self.x.position
  angle = math.atan(rise/run)
  self.x.speed = math.abs(self.top_speed * math.cos(angle))
  self.y.speed = math.abs(self.top_speed * math.sin(angle))
  rotation = angle + math.rad(90)
  if rise < 0 then
    self.y.speed = self.y.speed * -1
    rotation = angle - math.rad(90)
  end
  if run < 0 then
    self.x.speed = self.x.speed * -1
    rotation = angle - math.rad(90)
  end
  if self.y.speed < 0 and self.x.speed > 0 then
    rotation = angle + math.rad(90)
  end
  self.rotation.base_target = prior_rotations + rotation
  if math.abs(self.rotation.base_target - self.rotation.base) > math.rad(180) then
    if rotation < 0 then
      self.rotation.base_target = self.rotation.base_target + math.rad(360)
    else
      self.rotation.base_target = self.rotation.base_target - math.rad(360)
    end
  end
end

-- MOVE TOWARDS TARGET
function Tank:approachTarget(dt)
  local x_pos_poscont_contrib = self:controlDampener(self.x.position, self.x.target, self.vel_gain)
  local y_pos_poscont_contrib = self:controlDampener(self.y.position, self.y.target, self.vel_gain)
  local delta_x = (x_pos_poscont_contrib - self.x.position) / dt
  local delta_y = (y_pos_poscont_contrib - self.y.position) / dt
  if self.autonomous then
    self.x.velocity = self:closestToZero(delta_x, self.x.speed)
    self.y.velocity = self:closestToZero(delta_y, self.y.speed)
  end
  --check if arrived and if there are more points to go to
  if self:check_for_collision(self.x.path[self.path_index], self.y.path[self.path_index]) == true and self.x.path[self.path_index + 1] ~= nil then
    self.path_index = self.path_index + 1
    self:setTarget(self.x.path[self.path_index], self.y.path[self.path_index])
  end
end

function Tank:draw_path()
  love.graphics.setColor(255, 0, 0, 255)
  for i, x in ipairs(self.x.path) do
    if i < #self.x.path then
      y = self.y.path[i]
      love.graphics.line(x, y, self.x.path[i + 1], self.y.path[i + 1])
    end
  end
  love.graphics.reset()
end

-- add another node to the tanks path
function Tank:addWaypoint(x, y)
  -- find the closest node to the end
  local scaled_x_goal = math.floor(x/self.path_map_resolution)
  local scaled_y_goal = math.floor(y/self.path_map_resolution)
  local goal = find_node(scaled_x_goal, scaled_y_goal, self.path_map)
  if goal then
    if self.autonomous ~= true then
      self.autonomous = true
      self.path_index = 1
      self.path_length = 1
      self.x.path = {self.x.position}
      self.y.path = {self.y.position}
    end
    if x ~= nil and y ~= nil then
      -- determine the starting node for a*
      local scaled_x_start = math.floor(self.x.path[self.path_length]/self.path_map_resolution)
      local scaled_y_start = math.floor(self.y.path[self.path_length]/self.path_map_resolution)
      local start = find_node(scaled_x_start, scaled_y_start, self.path_map)
      raw_path = Astar(start, goal, self.path_map)
      cleaned_path = clean_path(raw_path)
      for i, node in ipairs(cleaned_path) do
        if i > 2 then
          table.insert(self.x.path, node.x * self.path_map_resolution)
          table.insert(self.y.path, node.y * self.path_map_resolution)
          self.path_length = self.path_length + 1
        end
      end
      table.insert(self.x.path, x)
      table.insert(self.y.path, y)
      self.path_length = self.path_length + 1
    end
  end
end

function clean_path(path)
  cleaned = {}
  for i, node in ipairs(path) do
    for j = i + 2, #path do
      -- something smart
    end
  end
  return path
end

function find_node(x, y, path_map)
  local node = nil
  for i, a_node in ipairs(path_map) do
    if a_node.x == x and a_node.y == y then
      node = a_node
    end
  end
  return node
end

-- Find Neighbouring nodes in the path_map
function find_neighbours(node, path_map)
  local neighbours = {}
  y = node.y
  x = node.x
  for _, a_node in ipairs(path_map) do
    if (a_node.x == x or a_node.x == x - 1 or a_node.x == x + 1) and (a_node.y == y or a_node.y == y + 1 or a_node.y == y - 1) and not (a_node.x == x and a_node.y == y) then
      table.insert(neighbours, a_node)
    end
  end
  return neighbours
end

-- Find lazy non euclid distance
function heuristic_distance(a, b)
  return ((b.x - a.x) * (b.x - a.x)) + ((b.y - a.y) * (b.y - a.y))
end

-- A* algorithim accepts start node and goal node arguements as {x_scaled, y_scaled} and path_map as a path_map
function Astar(start, goal, path_map)
  local open = {}
  local closed = {}
  start.g = 0
  start.h = heuristic_distance(start, goal)
  start.f = start.g + start.h
  table.insert(open, start)
  while not(next(open) == nil) do
    -- find node with smallest f!
    to_remove = 1
    q = open[to_remove]
    for i, node in ipairs(open) do
      if node.f < q.f then
        q = node
        to_remove = i
      end
    end
    table.remove(open, to_remove)
    -- find the neighbours of q and set them up
    for j, neighbour in ipairs(find_neighbours(q, path_map)) do
      if neighbour.x == goal.x and neighbour.y == goal.y then
        open = {}
        break
      end
      neighbour.g = q.g + heuristic_distance(neighbour, q)
      neighbour.h = heuristic_distance(neighbour, goal)
      neighbour.f = neighbour.g + neighbour.h
      -- check for duplicates in open and closed lists
      local add = true
      for _, a_node in ipairs(open) do
        if neighbour.x == a_node.x and neighbour.y == a_node.y then
          add = false
        end
      end
      for _, a_node in ipairs(closed) do
        if neighbour.x == a_node.x and neighbour.y == a_node.y then
          add = false
        end
      end
      if add == true then
        table.insert(open, neighbour)
      end
    end
    -- add q to the closed list
    table.insert(closed, q)
  end
  return closed
end

function Tank:reset(path_map)
  self.x.path = {self.x.position}
  self.y.path = {self.y.position}
  self.x.target = self.x.position
  self.y.target = self.y.position
  self.path_index = 1
  self.path_length = 1
  self.path_map = path_map
  self.x.velocity = 0
  self.y.velocity = 0
end

-- APPLY MOVEMENT and stuff
function Tank:update(dt, speed_modifier)
  -- MOVE
  if math.abs(self.rotation.base - self.rotation.base_target) < self.acceptable_rad_error then
    self.x.position = self.x.position + self.x.velocity * dt * speed_modifier
    self.y.position = self.y.position + self.y.velocity * dt * speed_modifier
    self.hitbox.x_max = self.x.position + self.hitbox.offset
    self.hitbox.y_max = self.y.position + self.hitbox.offset
    self.hitbox.x_min = self.x.position - self.hitbox.offset
    self.hitbox.y_min = self.y.position - self.hitbox.offset
    -- CHECK POSITION WITHIN BOUNDS
    if self.hitbox.x_max > self.x.bound then
      self.x.position = self.x.bound - self.hitbox.offset
    elseif self.hitbox.x_min < 0 then
      self.x.position = self.hitbox.offset
    end
    if self.hitbox.y_max > self.y.bound then
      self.y.position = self.y.bound - self.hitbox.offset
    elseif self.hitbox.y_min < 0 then
      self.y.position = self.hitbox.offset
    end
  end
  self.rotation.turrent = self:controlDampener(self.rotation.turrent, self.rotation.turrent_target, self.rot_gain)
  self.rotation.base = self:controlDampener(self.rotation.base, self.rotation.base_target, self.rot_gain)
end

return Tank
