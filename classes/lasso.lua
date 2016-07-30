local Lasso = {}
Lasso.__index = Lasso

function Lasso.create(x, y)
  local L = {}
  setmetatable(L, Lasso)
  L.start_x = x
  L.start_y = y
  L.end_x = x
  L.end_y = y
  return L
end

function Lasso:update(x, y)
  self.end_x = x
  self.end_y = y
end

function Lasso:draw()
  lg.setColor(200, 10, 200, 255)
  lg.line(self.start_x, self.start_y, self.end_x, self.start_y, self.end_x, self.end_y, self.start_x, self.end_y, self.start_x, self.start_y)
end

function Lasso:returnSelectedTanks(tanks, offset)
  self.start_x = self.start_x - offset.x
  self.end_x = self.end_x - offset.x
  self.start_y = self.start_y - offset.y
  self.end_y = self.end_y - offset.y
  local selected = {}
  local min_x = math.min(self.start_x, self.end_x)
  local max_x = math.max(self.start_x, self.end_x)
  local min_y = math.min(self.start_y, self.end_y)
  local max_y = math.max(self.start_y, self.end_y)
  for j, tank in ipairs(tanks) do 
    if tank.x.position > min_x and tank.x.position < max_x and tank.y.position > min_y and tank.y.position < max_y then 
      table.insert(selected, tank.id)
    end
  end
  return selected
end

return Lasso
