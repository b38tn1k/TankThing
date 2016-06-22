-- TANK Class
local t = {}

-- SET UP THE TANK BOUNDARIES
local function init(x_position, y_position, x_bound, y_bound, top_speed, projectile_speed, projectile_delegate, img1_pth, img2_pth, img3_pth)
  -- CONSTANTS AND VARIABLES
  t.top_speed = 400
  t.vel_gain = 0.12
  t.rot_gain = 0.12
  t.acceptable_lin_error = 0.01
  t.acceptable_rad_error = math.rad(45)
  t.autonomous = true
  t.speed = 0

  t.projectile = {}
  t.projectile.speed = 0
  t.projectile.img_path = ""

  t.x = {}
  t.x.position = 0
  t.x.target = 0
  t.x.speed = 0
  t.x.bound = 0
  t.x.velocity = 0
  t.x.image_offset = 0

  t.y = {}
  t.y.position = 0
  t.y.target = 0
  t.y.velocity = 0
  t.y.speed = 0
  t.y.bound = 0
  t.y.image_offset = 0

  t.rotation = {}
  t.rotation.base = 0
  t.rotation.base_target = 0
  t.rotation.turrent = 0
  t.rotation.turrent_target = 0

  t.sprite = {}
  t.sprite.layer1 = {}
  t.sprite.layer2 = {}

  t.hitbox = {}
  t.projectiles = {}

  t.x.bound, t.y.bound = x_bound, y_bound
  t.x.position, t.y.position = x_position, y_position
  t.top_speed = top_speed
  t.projectile.speed = projectile_speed
  t.projectile.delegate = projectile_delegate
  t.sprite.layer1.img = love.graphics.newImage(img1_pth)
  t.sprite.layer1.width = t.sprite.layer1.img:getWidth()
  t.sprite.layer1.height = t.sprite.layer1.img:getHeight()
  t.sprite.layer2.img = love.graphics.newImage(img2_pth)
  t.sprite.layer2.width = t.sprite.layer2.img:getWidth()
  t.sprite.layer2.height = t.sprite.layer2.img:getHeight()
  t.projectile.img_path = img3_pth
  t.hitbox.x_max = t.x.position
  t.hitbox.y_max = t.y.position
  t.hitbox.x_min = t.x.position - t.sprite.layer1.width
  t.hitbox.y_min = t.y.position - t.sprite.layer1.height
end
t.init = init

local function debug_view()
  -- DEBUG vv
  position_string = "POS: ".. (string.format("%.2f", t.x.position)) .. ",\t" .. (string.format("%.2f", t.y.position))
  target_string = "TAR: ".. (string.format("%.2f", t.x.target)) .. ",\t" .. (string.format("%.2f", t.y.target))
  velocity_string = "VEL: ".. (string.format("%.2f", t.x.velocity)) .. ",\t" .. (string.format("%.2f", t.y.velocity))
  orientation_string = "ORI: ".. string.format("%.2f", t.rotation.base) .. "\tTAR: " .. string.format("%.2f", t.rotation.base_target)
  love.graphics.setColor(200, 200, 255, 255)
  love.graphics.setFont(love.graphics.newFont(15))
  -- love.graphics.rectangle("fill", t.x.position - 15, t.y.position - 1, 30, 2)
  -- love.graphics.rectangle("fill", t.x.position - 1, t.y.position - 15, 2, 30)
  love.graphics.printf(position_string,10, t.y.bound - 64, 500, 'left')
  love.graphics.printf(target_string, 10, t.y.bound - 48, 500, 'left')
  love.graphics.printf(velocity_string, 10, t.y.bound - 32, 500, 'left')
  love.graphics.printf(orientation_string, 10, t.y.bound - 16, 500, 'left')
  -- HIT BOX
  love.graphics.rectangle("fill", t.hitbox.x_max, t.hitbox.y_min, 2, 2)
  love.graphics.rectangle("fill", t.hitbox.x_min, t.hitbox.y_max, 2, 2)
  love.graphics.rectangle("fill", t.hitbox.x_min, t.hitbox.y_min, 2, 2)
  love.graphics.rectangle("fill", t.hitbox.x_max, t.hitbox.y_max, 2, 2)
  -- HIT BOX
  love.graphics.reset()
end
t.debug_view = debug_view

-- DRAW THE TANK
local function draw()
  love.graphics.reset()
  love.graphics.draw(t.sprite.layer1.img, t.x.position - math.floor(t.sprite.layer1.width/2), t.y.position - math.floor(t.sprite.layer1.height/2), t.rotation.base, 1, 1, t.sprite.layer1.width/2, t.sprite.layer1.height/2)
  for i, projectile in ipairs(t.projectiles) do
    projectile:draw()
  end
  love.graphics.draw(t.sprite.layer2.img, t.x.position  - math.floor(t.sprite.layer2.width/2), t.y.position  - math.floor(t.sprite.layer2.height/2), t.rotation.base + t.rotation.turrent, 1, 1, t.sprite.layer2.width/2, t.sprite.layer2.height/2)
end
t.draw = draw

-- ROTATE UPPER LAYER
local function rotate(dt)
  if t.rotation.turrent_target > math.rad(110) then
    t.rotation.turrent_target = math.rad(100)
  elseif t.rotation.turrent_target < 0 - math.rad(110) then
    t.rotation.turrent_target = 0 - math.rad(100)
  end
  if love.keyboard.isDown("lshift") then
    t.rotation.turrent_target  = 0
  end
  if love.keyboard.isDown("q") then
    t.rotation.turrent_target = t.rotation.turrent_target - 0.1
  end
  if love.keyboard.isDown("e") then
    t.rotation.turrent_target = t.rotation.turrent_target + 0.1
  end
  t.rotation.turrent = controlDampener(t.rotation.turrent, t.rotation.turrent_target, t.rot_gain)
  t.rotation.base = controlDampener(t.rotation.base, t.rotation.base_target, t.rot_gain)
end
t.rotate = rotate

-- DAMPEN CHANGES IN VELOCITY, POSITION, ETC
function controlDampener(value, target, factor)
  new_value = value
  error = target - value
  if math.abs(error) > t.acceptable_lin_error then
    new_value = value + error * factor
  end
  return new_value
end

-- UPDATE VELOCITIES
local function update_velocities()
  t.y.velocity = t.speed * math.sin(t.rotation.base + math.rad(90))
  t.x.velocity = t.speed * math.cos(t.rotation.base + math.rad(90))
end
t.update_velocities = update_velocities

-- TURN LEFT
local function turn_left()
  t.rotation.base_target = t.rotation.base_target - 0.1
  t.update_velocities()
end
t.turn_left = turn_left

-- TURN RIGHT
local function turn_right()
  t.rotation.base_target = t.rotation.base_target + 0.1
  t.update_velocities()
end
t.turn_right = turn_right

-- GO FORWARD
local function forwards()
  t.speed = controlDampener(t.speed, 0 - t.top_speed, t.vel_gain)
  t.update_velocities()
end
t.forwards = forwards

-- GO BACKWARDS
local function backwards()
  t.speed = controlDampener(t.speed, t.top_speed, t.vel_gain)
  t.update_velocities()
end
t.backwards = backwards

-- STOP
local function slow_to_stop()
  t.speed = controlDampener(t.speed, 0, t.vel_gain)
  t.update_velocities()
end
t.slow_to_stop = slow_to_stop

-- EXCITING INERTIAL WASD CONTROL
local function userControl()
  if love.keyboard.isDown("left", "a", "right", "d", "up", "w", "down", "s") then
    t.autonomous = false
    t.y.target = t.y.position
    t.x.target = t.x.position
  end
  if love.keyboard.isDown("left", "a") then
    t.turn_left()
  elseif love.keyboard.isDown("right", "d") then
    t.turn_right()
  end
  if love.keyboard.isDown("up", "w") then
    t.forwards()
  elseif love.keyboard.isDown("down", "s") then
    t.backwards()
  else
    t.slow_to_stop()
  end
end
t.userControl = userControl

-- SET UP AUTO TARGET FROM MOUSE CLICK OR SOMETHING. BEWARE: MY TRIG IS HACKY
local function setWaypoint(x, y)
  prior_rotations = math.rad(360)*(math.floor((t.rotation.base + math.rad(180))/math.rad(360)))
  rotation = 0
  t.autonomous = true
  t.y.target = y + t.sprite.layer1.height/2
  t.x.target = x + t.sprite.layer1.width/2
  rise = t.y.target - t.y.position
  run = t.x.target - t.x.position
  angle = math.atan(rise/run)
  t.x.speed = math.abs(t.top_speed * math.cos(angle))
  t.y.speed = math.abs(t.top_speed * math.sin(angle))
  rotation = angle + math.rad(90)
  if rise < 0 then
    t.y.speed = t.y.speed * -1
    rotation = angle - math.rad(90)
  end
  if run < 0 then
    t.x.speed = t.x.speed * -1
    rotation = angle - math.rad(90)
  end
  if t.y.speed < 0 and t.x.speed > 0 then
    rotation = angle + math.rad(90)
  end
  t.rotation.base_target = prior_rotations + rotation
  if math.abs(t.rotation.base_target - t.rotation.base) > math.rad(180) then
    if rotation < 0 then
      t.rotation.base_target = t.rotation.base_target + math.rad(360)
    else
      t.rotation.base_target = t.rotation.base_target - math.rad(360)
    end
  end
end
t.setWaypoint = setWaypoint

local function fire_main_weapon()
  projectile = t.projectile.delegate.create(t.projectile.speed, t.projectile.img_path, t.x.position, t.y.position, (t.rotation.turrent + t.rotation.base), t.x.bound, t.y.bound) --speed, x_pos, y_pos, rotation, x_bound, y_bound
  table.insert(t.projectiles, projectile)
end
t.fire_main_weapon = fire_main_weapon

-- RETURN CLOSEST VALUE TO ZERO
local function closestToZero(x, y)
  new_value = math.min(math.abs(x), math.abs(y))
  if x < 0 and y < 0 then
    new_value = new_value * -1
  end
  return new_value
end

-- MOVE TOWARDS TARGET
local function approachTarget(dt)
  x_pos_poscont_contrib = controlDampener(t.x.position, t.x.target, t.vel_gain)
  y_pos_poscont_contrib = controlDampener(t.y.position, t.y.target, t.vel_gain)
  delta_x = (x_pos_poscont_contrib - t.x.position) / dt
  delta_y = (y_pos_poscont_contrib - t.y.position) / dt
  if t.autonomous then
    t.x.velocity = closestToZero(delta_x, t.x.speed)
    t.y.velocity = closestToZero(delta_y, t.y.speed)
  end
end
t.approachTarget = approachTarget

-- DRIFT TOWARDS MOUSE
local function followMouse(dt)
  x_pos_poscont_contrib = controlDampener(t.x.position, t.x.target, t.vel_gain)
  y_pos_poscont_contrib = controlDampener(t.y.position, t.y.target, t.vel_gain)
  delta_x = (x_pos_poscont_contrib - t.x.position) / dt
  delta_y = (y_pos_poscont_contrib - t.y.position) / dt
  t.x.velocity = delta_x
  t.y.velocity = delta_y
end
t.followMouse = followMouse

-- APPLY MOVEMENT and stuff. pass world, other players into this function
local function update(dt, speed_modifier)
  -- MOVE
  if math.abs(t.rotation.base - t.rotation.base_target) < t.acceptable_rad_error then
    t.x.position = t.x.position + t.x.velocity * dt * speed_modifier
    t.y.position = t.y.position + t.y.velocity * dt * speed_modifier
    t.hitbox.x_max = t.x.position
    t.hitbox.y_max = t.y.position
    t.hitbox.x_min = t.x.position - t.sprite.layer1.width
    t.hitbox.y_min = t.y.position - t.sprite.layer1.height
    -- CHECK POSITION WITHIN BOUNDS
    if t.hitbox.x_max > t.x.bound then
      t.x.position = t.x.bound
    elseif t.hitbox.x_min < 0 then
      t.x.position = t.sprite.layer1.width
    end
    if t.hitbox.y_max > t.y.bound then
      t.y.position = t.y.bound
    elseif t.hitbox.y_min < 0 then
      t.y.position = t.sprite.layer1.height
    end
  end
  -- UPDATE PROJECTILES (MOVE)
  for i, projectile in ipairs(t.projectiles) do
    projectile:update(dt)
    if projectile.x.position > t.x.bound or projectile.x.position < 0 then
      table.remove(t.projectiles, i)
    end
    if projectile.y.position > t.y.bound or projectile.y.position < 0 then
      table.remove(t.projectiles, i)
    end
  end
end
t.update = update

return t
