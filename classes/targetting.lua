function targetting(tanks)
  for i, tank in ipairs(tanks) do
    local ranges = {}
    local target = {}
    local the_target = {}
    for j, others in ipairs(tanks) do
      if others.team ~= tank.team then
        -- find all targets within range
        local rel_x = (tank.x.position - others.x.position) * (tank.x.position - others.x.position)
        local rel_y = (tank.y.position - others.y.position) * (tank.y.position - others.y.position)
        local distance = math.sqrt(rel_x + rel_y)
        if distance < tank.projectile.range then
          target.x = others.x.position
          target.y = others.y.position
          target.distance = distance
          target.id = others.id
          target.angle = findAngle(tank, others)
          table.insert(ranges, target)
        end
      end
    end
    if next(ranges) ~= nil then
      -- find the most likely target (the closest one)
      the_target.distance = 10000000000 -- lazier to initialise this way than deal with nil
      for _, range in ipairs(ranges) do
        if range.distance < the_target.distance then
          the_target = {}
          the_target = range
        end
      end
      -- Choose to fire or aim betterer
      if math.abs(majorAngle(the_target.angle) - majorAngle(tank.rotation.turrent)) < math.rad(5) then 
        game.makeTankShoot(tank)
      end
      tank.rotation.turrent_target = the_target.angle
    else
     tank.rotation.turrent_target =  majorAngle(tank.rotation.base)
    end
    -- move this to tank:update. fixes angles so turrent is lazy
    if math.abs(tank.rotation.turrent_target - tank.rotation.turrent) > math.rad(180) then 
      if (tank.rotation.turrent_target > tank.rotation.turrent) then 
        tank.rotation.turrent_target = tank.rotation.turrent_target - math.rad(360)
      else 
        tank.rotation.turrent_target = tank.rotation.turrent_target + math.rad(360)
      end
    end
    if tank.rotation.turrent > math.rad(360) and tank.rotation.turrent_target > math.rad(360) then 
      tank.rotation.turrent = tank.rotation.turrent - math.rad(360)
      tank.rotation.turrent_target = tank.rotation.turrent_target - math.rad(360)
    end
    if tank.rotation.turrent < 0 and tank.rotation.turrent_target < 0 then 
      tank.rotation.turrent = tank.rotation.turrent + math.rad(360)
      tank.rotation.turrent_target = tank.rotation.turrent_target + math.rad(360)
    end
  end
end

function findAngle(tank, target)
  atan = math.atan2
  rad = math.rad
  local angle = 0
  local dx = tank.x.position - target.x.position
  local dy = tank.y.position - target.y.position
  angle = math.rad(360) - atan(dx, dy)
  return angle
end

function majorAngle(angle)
  return (angle - math.floor(angle/math.rad(360))*math.rad(360))
end
