function targetting(tanks)
  local ranges = {}
  for i, tank in ipairs(tanks) do
    for j, others in ipairs(tanks) do
      if others.team ~= tank.team then
        -- find all targets within range
        local rel_x = (tank.x.position - others.x.position) * (tank.x.position - others.x.position)
        local rel_y = (tank.y.position - others.y.position) * (tank.y.position - others.y.position)
        local distance = math.sqrt(rel_x + rel_y)
        if distance < tank.projectile.range then
          local target = {}
          target.x = others.x.position
          target.y = others.y.position
          target.distance = distance
          target.id = others.id
          target.angle = findAngle(tank, others)
          table.insert(ranges, target)
        end
      end
    end
    local the_target = {}
    if next(ranges) ~= nil then
      -- find the most likely target (the closest one)
      the_target.distance = 10000000000 -- easier to initialise this way than deal with nil
      for _, range in ipairs(ranges) do
        if range.distance < the_target.distance then
          the_target = {}
          the_target = range
        end
      end
      tank.turrent_idle = false
      tank.rotation.turrent_target = the_target.angle
    else
      tank.rotation.turrent_target = 0
    end
  end
end

function findAngle(tank, target)
  -- I know I should have figured out a proper coordinate system a long time ago
  -- like, when I was doing the add waypoint stuff
  -- but I didn't
  -- next time I will
  -- learning!
  atan = math.atan2
  rad = math.rad
  local angle = 0
  local dx = tank.x.position - target.x.position
  local dy = tank.y.position - target.y.position
  angle = tank.rotation.base - atan(dx, dy)
  return angle
end
