-- World Class
local World = {}
World.__index = World

-- TODO: clean this - make a 'render world' method and seperate it from the creation section

function World.create(width, height)
  local w = {}
  setmetatable(w, World)
  math.randomseed(os.time() * 1000)
  for i = 1, 100 do   -- clear out start of random buffer
    math.random()
  end
  w.seed = 10
  w.scale = 0.002
  w.width, w.height = width, height
  w.map = {}
  return w
end

function World:generate()
  self.seed = math.random() * 100
  for i = 1, self.width do
      self.map[i] = {}
      for j = 1, self.height do
          self.map[i][j] = love.math.noise(self.scale * i + self.seed, self.scale * j + self.seed)
      end
  end
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  love.graphics.setCanvas(self.canvas)
  for i = 1, self.width do
    for j = 1, self.height do
      if self.map[i][j] < 0.3 then
        love.graphics.setColor(50, 100, 255, 255)
      elseif self.map[i][j] < 0.35 then
        love.graphics.setColor(200, 150, 0, 255)
      elseif self.map[i][j] < 0.5 then
        love.graphics.setColor(80, 100, 0, 255)
      elseif self.map[i][j] < 0.9 then
        love.graphics.setColor(40, 100, 40, 255)
      else
        love.graphics.setColor(30, 80, 10, 255)
      end
      love.graphics.point( i - 1, j - 1 )
    end
  end
  love.graphics.setCanvas()
end

function World:draw()
  love.graphics.reset()
  love.graphics.draw(self.canvas)
end

return World
