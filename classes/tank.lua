-- TANK Class
local Tank = {}
Tank.__index = Tank

-- SET UP THE TANK BOUNDARIES
function Tank.create(id, x_position, y_position, x_bound, y_bound, top_speed, projectile_speed, img1_pth, img2_pth, img3_pth)
  -- CONSTANTS AND VARIABLES
  local t = {}
  setmetatable( t, Tank )
  t.active = false
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
  t.sprite_layer1 = {}
  t.sprite_layer2 = {}
  t.hitbox = {}
  t.id = id
  t.x.position = x_position
  t.y.position = y_position
  t.x.bound = x_bound
  t.y.bound = y_bound
  t.top_speed = top_speed
  t.projectile.speed = projectile_speed
  t.sprite_layer1.img = love.graphics.newImage(img1_pth)
  t.sprite_layer2.img = love.graphics.newImage(img2_pth)
  t.projectile.img_path = img3_pth
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
  t.sprite_layer1.width = t.sprite_layer1.img:getWidth()
  t.sprite_layer1.height = t.sprite_layer1.img:getHeight()
  t.sprite_layer2.width = t.sprite_layer2.img:getWidth()
  t.sprite_layer2.height = t.sprite_layer2.img:getHeight()
  t.hitbox.x_max = t.x.position
  t.hitbox.y_max = t.y.position
  t.hitbox.x_min = t.x.position - t.sprite_layer1.width
  t.hitbox.y_min = t.y.position - t.sprite_layer1.height
  return t
end

function Tank:debug_view()
  position_string = "POS: ".. (string.format("%.2f", self.x.position)) .. ",\t" .. (string.format("%.2f", self.y.position))
  target_string = "TAR: ".. (string.format("%.2f", self.x.target)) .. ",\t" .. (string.format("%.2f", self.y.target))
  velocity_string = "VEL: ".. (string.format("%.2f", self.x.velocity)) .. ",\t" .. (string.format("%.2f", self.y.velocity))
  orientation_string = "ORI: ".. string.format("%.2f", self.rotation.base) .. "\tTAR: " .. string.format("%.2f", self.rotation.base_target)
  love.graphics.setColor(200, 200, 255, 255)
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
function Tank:drawLayer1()
  love.graphics.draw(self.sprite_layer1.img, self.x.position - math.floor(self.sprite_layer1.width/2), self.y.position - math.floor(self.sprite_layer1.height/2), self.rotation.base, 1, 1, self.sprite_layer1.width/2, self.sprite_layer1.height/2)
end

function Tank:drawLayer2()
  love.graphics.draw(self.sprite_layer2.img, self.x.position  - math.floor(self.sprite_layer1.width/2), self.y.position  - math.floor(self.sprite_layer1.height/2), self.rotation.base + self.rotation.turrent, 1, 1, self.sprite_layer2.width/2, self.sprite_layer2.height/2)
end

-- ROTATE UPPER LAYER
function Tank:rotate(dt)
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
  self.rotation.turrent = self:controlDampener(self.rotation.turrent, self.rotation.turrent_target, self.rot_gain)
  self.rotation.base = self:controlDampener(self.rotation.base, self.rotation.base_target, self.rot_gain)
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

-- EXCITING INERTIAL WASD CONTROL
function Tank:userControl()
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
end

-- SET UP AUTO TARGET FROM MOUSE CLICK OR SOMETHING. BEWARE: MY TRIG IS HACKY
function Tank:setWaypoint(x, y)
  prior_rotations = math.rad(360)*(math.floor((self.rotation.base + math.rad(180))/math.rad(360)))
  rotation = 0
  self.autonomous = true
  self.y.target = y + self.sprite_layer1.height/2
  self.x.target = x + self.sprite_layer1.width/2
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

function Tank:fire_main_weapon()
  x_position = self.x.position - self.sprite_layer1.width/2
  y_position = self.y.position - self.sprite_layer1.height/2
  data = {self.id, self.projectile.speed, self.projectile.img_path, x_position, y_position, (self.rotation.turrent + self.rotation.base), self.x.bound, self.y.bound, self.sprite_layer2.height*2}
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

-- MOVE TOWARDS TARGET
function Tank:approachTarget(dt)
  x_pos_poscont_contrib = self:controlDampener(self.x.position, self.x.target, self.vel_gain)
  y_pos_poscont_contrib = self:controlDampener(self.y.position, self.y.target, self.vel_gain)
  delta_x = (x_pos_poscont_contrib - self.x.position) / dt
  delta_y = (y_pos_poscont_contrib - self.y.position) / dt
  if self.autonomous then
    self.x.velocity = self:closestToZero(delta_x, self.x.speed)
    self.y.velocity = self:closestToZero(delta_y, self.y.speed)
  end
end

-- DRIFT TOWARDS MOUSE
function Tank:followMouse(dt)
  x_pos_poscont_contrib = self:controlDampener(self.x.position, self.x.target, self.vel_gain)
  y_pos_poscont_contrib = self:controlDampener(self.y.position, self.y.target, self.vel_gain)
  delta_x = (x_pos_poscont_contrib - self.x.position) / dt
  delta_y = (y_pos_poscont_contrib - self.y.position) / dt
  self.x.velocity = delta_x
  self.y.velocity = delta_y
end

-- APPLY MOVEMENT and stuff. pass world, other players into this function
function Tank:update(dt, speed_modifier)
  -- MOVE
  if math.abs(self.rotation.base - self.rotation.base_target) < self.acceptable_rad_error then
    self.x.position = self.x.position + self.x.velocity * dt * speed_modifier
    self.y.position = self.y.position + self.y.velocity * dt * speed_modifier
    self.hitbox.x_max = self.x.position
    self.hitbox.y_max = self.y.position
    self.hitbox.x_min = self.x.position - self.sprite_layer1.width
    self.hitbox.y_min = self.y.position - self.sprite_layer1.height
    -- CHECK POSITION WITHIN BOUNDS
    if self.hitbox.x_max > self.x.bound then
      self.x.position = self.x.bound
    elseif self.hitbox.x_min < 0 then
      self.x.position = self.sprite_layer1.width
    end
    if self.hitbox.y_max > self.y.bound then
      self.y.position = self.y.bound
    elseif self.hitbox.y_min < 0 then
      self.y.position = self.sprite_layer1.height
    end
  end
end

return Tank
