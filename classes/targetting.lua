function targetting(tanks)
  for i, tank in ipairs(tanks) do
    for j, others in ipairs(tanks) do
      if others.team ~= tank.team then
        local rel_x = (tank.x.position - others.x.position) * (tank.x.position - others.x.position)
        local rel_y = (tank.y.position - others.y.position) * (tank.y.position - others.y.position)
        if math.sqrt(rel_x + rel_y) < tank.projectile.range then
          game.make_tank_shoot(tank)
        end
      end
    end
  end
end
