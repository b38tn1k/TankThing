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
  t.rot_gain = 0.1
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
  t.team = 0
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
  t.reverse_path = {}
  t.top_speed = top_speed
  t.projectile.speed = projectile_speed
  t.projectile.lifespan = projectile_lifespan
  t.projectile.range = projectile_speed * projectile_lifespan
  t.sprite.layer1.img = lg.newImage(imgs[2])
  t.sprite.layer2.img = lg.newImage(imgs[3])
  t.sprite.selected.img = lg.newImage(imgs[1])
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

function Tank:init(id, team, node, theta)
  self.id = id
  self.team = team
  self.x.position = node.x * self.path_map_resolution
  self.y.position = node.y * self.path_map_resolution
  table.insert(self.x.path, self.x.position)
  table.insert(self.y.path, self.y.position)
  self.rotation.base = theta
  self.rotation.base_target = theta
end

function Tank:drawDebug()
  local position_string = "POS: ".. (string.format("%.2f", self.x.position)) .. ",\t" .. (string.format("%.2f", self.y.position))
  local target_string = "TAR: ".. (string.format("%.2f", self.x.target)) .. ",\t" .. (string.format("%.2f", self.y.target))
  local velocity_string = "VEL: ".. (string.format("%.2f", self.x.velocity)) .. ",\t" .. (string.format("%.2f", self.y.velocity))
  local orientation_string = "ORI: ".. string.format("%.2f", self.rotation.base) .. "\tTAR: " .. string.format("%.2f", self.rotation.base_target)
  local screen_string = "SCREEN DIMS W: " .. self.x.bound .. " H: " .. self.y.bound
  lg.setColor(255, 0, 0, 255)
  lg.setFont(lg.newFont(15))
  lg.printf(position_string,10, 64, 500, 'left')
  lg.printf(target_string, 10, 48, 500, 'left')
  lg.printf(velocity_string, 10, 32, 500, 'left')
  lg.printf(orientation_string, 10, 16, 500, 'left')
  lg.printf(screen_string, 10, 80, 500, 'left')
  -- HIT BOX
  lg.rectangle("fill", self.hitbox.x_max, self.hitbox.y_min, 2, 2)
  lg.rectangle("fill", self.hitbox.x_min, self.hitbox.y_max, 2, 2)
  lg.rectangle("fill", self.hitbox.x_min, self.hitbox.y_min, 2, 2)
  lg.rectangle("fill", self.hitbox.x_max, self.hitbox.y_max, 2, 2)
  lg.rectangle("fill", self.x.position, self.y.position, 2, 2)
  -- HIT BOX
  lg.reset()
end

-- DRAW THE TANK
function Tank:drawLayer1()
  lg.draw(self.sprite.layer1.img, self.x.position, self.y.position, self.rotation.base, 1, 1, self.sprite.layer1.width/2, self.sprite.layer1.height/2)
end

function Tank:drawHalo(shader)
  lg.setShader(shader)
  lg.draw(self.sprite.selected.img, self.x.position, self.y.position, self.rotation.base, 1, 1, self.sprite.selected.width/2, self.sprite.selected.height/2)
  lg.setShader()
end

function Tank:drawLayer2()
  -- lg.draw(self.sprite.layer2.img, self.x.position, self.y.position, self.rotation.base + self.rotation.turrent, 1, 1, self.sprite.layer2.width/2, self.sprite.layer2.height/2)
  lg.draw(self.sprite.layer2.img, self.x.position, self.y.position, self.rotation.base + self.rotation.turrent, 1, 1, self.sprite.layer2.width/2, self.sprite.layer2.height/2)
end

-- ROTATE UPPER LAYER
function Tank:rotateTurrent()
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
function Tank:updateVelocities()
  self.y.velocity = self.speed * math.sin(self.rotation.base + math.rad(90))
  self.x.velocity = self.speed * math.cos(self.rotation.base + math.rad(90))
end

-- TURN LEFT
function Tank:turnLeft()
  self.rotation.base_target = self.rotation.base_target - 0.05
  self:updateVelocities()
end

-- TURN RIGHT
function Tank:turnRight()
  self.rotation.base_target = self.rotation.base_target + 0.05
  self:updateVelocities()
end

-- GO FORWARD
function Tank:forwards()
  self.speed = self:controlDampener(self.speed, 0 - self.top_speed, self.vel_gain)
  self:updateVelocities()
end

-- GO BACKWARDS
function Tank:backwards()
  self.speed = self:controlDampener(self.speed, self.top_speed, self.vel_gain)
  self:updateVelocities()
end

-- STOP
function Tank:slow2stop()
  self.speed = self:controlDampener(self.speed, 0, self.vel_gain)
  self:updateVelocities()
end

function Tank:check4collision(x, y)
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

function Tank:fireMainWeapon()
  data = {self.id, self.team, self.projectile.speed, self.projectile.lifespan, self.projectile.img_path, self.x.position, self.y.position, self.rotation.turrent + self.rotation.base, self.x.bound, self.y.bound, self.sprite.layer2.height*2}
  return data
end

-- RETURN CLOSEST VALUE TO ZERO
function Tank:closest2Zero(x, y)
  new_value = math.min(math.abs(x), math.abs(y))
  if x < 0 and y < 0 then
    new_value = new_value * -1
  end
  return new_value
end

-- EXCITING INERTIAL WASD CONTROL
function Tank:userControl()
  if self.selected == true then
    if love.keyboard.isDown("left", "a", "right", "d", "up", "w", "down", "s", "h", "j", "k", "l") then
      self.autonomous = false
      self.y.target = self.y.position
      self.x.target = self.x.position
    end
    if love.keyboard.isDown("left", "a", "h") then
      self:turnLeft()
    elseif love.keyboard.isDown("right", "d", "l") then
      self:turnRight()
    end
    if love.keyboard.isDown("up", "w", "k") then
      self:forwards()
    elseif love.keyboard.isDown("down", "s", "j") then
      self:backwards()
    else
      self:slow2stop()
    end
  else
    self:slow2stop()
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
    self.x.velocity = self:closest2Zero(delta_x, self.x.speed)
    self.y.velocity = self:closest2Zero(delta_y, self.y.speed)
  end
  --check if arrived and if there are more points to go to
  if self:check4collision(self.x.path[self.path_index], self.y.path[self.path_index]) == true and self.x.path[self.path_index + 1] ~= nil then
    self.path_index = self.path_index + 1
    self:setTarget(self.x.path[self.path_index], self.y.path[self.path_index])
  end
end

function Tank:drawPath()
  lg.setColor(255, 0, 0, 255)
  for i, x in ipairs(self.x.path) do
    if i < #self.x.path then
      y = self.y.path[i]
      lg.line(x, y, self.x.path[i + 1], self.y.path[i + 1])
    end
  end
  -- lg.setColor(0, 0, 255, 255)
  -- for i, node in ipairs(self.reverse_path) do
  --   if i < #self.reverse_path - 1 then
  --     lg.line(node.x * self.path_map_resolution, node.y * self.path_map_resolution, self.reverse_path[i + 1].x * self.path_map_resolution, self.reverse_path[i + 1].y * self.path_map_resolution)
  --   end
  -- end
  lg.reset()
end

-- add another node to the tanks path
function Tank:addWaypoint(x, y)
  -- find the closest node to the end
  local scaled_x_goal = math.floor(x/self.path_map_resolution)
  local scaled_y_goal = math.floor(y/self.path_map_resolution)
  local goal = findNode(scaled_x_goal, scaled_y_goal, self.path_map)
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
      local start = findNode(scaled_x_start, scaled_y_start, self.path_map)
      raw_path = Astar(start, goal, self.path_map)
      -- reverse = Astar(goal, start, self.path_map)
      -- for i, node in ipairs(reverse) do
      --   if i > 2  and i < #reverse - 2 then
      --     table.insert(self.reverse_path, node)
      --   end
      -- end
      for i, node in ipairs(raw_path) do
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
  -- self:userControl()
  -- self:rotateTurrent()
  self:approachTarget(dt)
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
  -- if self.rotation.turrent_target > math.rad(110) then
  --   self.rotation.turrent_target = math.rad(100)
  -- elseif self.rotation.turrent_target < 0 - math.rad(110) then
  --   self.rotation.turrent_target = 0 - math.rad(100)
  -- end

  self.rotation.turrent = self:controlDampener(self.rotation.turrent, self.rotation.turrent_target, self.rot_gain)
  self.rotation.base = self:controlDampener(self.rotation.base, self.rotation.base_target, self.rot_gain)
end

return Tank
