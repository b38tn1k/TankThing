function targetting(tanks, projectiles)
  for i, tank in ipairs(tanks) do
    for j, others in ipairs(tanks) do
      if others.team ~= tank.team then
        local rel_x = (tank.x.position - others.x.position) * (tank.x.position - others.x.position)
        local rel_y = (tank.y.position - others.y.position) * (tank.y.position - others.y.position)
        if math.sqrt(rel_x + rel_y) < tank.projectile.range then
          local can_fire = true
          for _, proj in ipairs(projectiles) do
            if proj.parent_id == tank.id then
              can_fire = false
            end
          end
          if can_fire == true then
            game.make_tank_shoot(tank)
          end
        end
      end
    end
  end
end
