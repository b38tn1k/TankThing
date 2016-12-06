local Factory = {}
Factory.__index = Factory

function Factory.create(x, y, img)
  local f = {}
  setmetatable(f, Factory)
  f.x = x
  f.y = y
  f.img = img
  f.texture = lg.newImage(img)
  f.width = f.texture:getWidth()
  f.height = f.texture:getHeight()
  f.health = 100
  return f
end

function Factory:draw(offset)
lg.draw(self.texture, self.x + offset.x, self.y + offset.y, 0, 1, 1, self.width/2, self.height/2)
end

return Factory
