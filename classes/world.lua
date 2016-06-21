-- World Class
local World = {}
World.__index = World

function World.create()
  local w = {}
  setmetatable(w, World)
  math.randomseed(os.time() * 1000)
  temp_seed = 0
  w.seed = math.random()
  while true do
    temp_seed = math.random()
    if temp_seed < 0.03  and temp_seed > 0.01 then
      w.seed = temp_seed/10
      break
    end
  end
  print (w.seed)
  w.window = {}
  w.window.width, w.window.height, w.window.FLAGS = love.window.getMode()
  -- make terrain canvas thing
  w.grid = {}
  for i = 1, w.window.width do
      w.grid[i] = {}
      for j = 1, w.window.height do
          w.grid[i][j] = love.math.noise(w.seed * i, w.seed * j)
      end
  end
  w.canvas = love.graphics.newCanvas(w.window.width, w.window.height)
  love.graphics.setCanvas(w.canvas)
  for i = 1, w.window.width do
    for j = 1, w.window.height do
      if w.grid[i][j] < 0.3 then
        love.graphics.setColor(0, 0, 255, 255)
      else
        love.graphics.setColor(0, 255, 0, 255)
      end
      love.graphics.point( i - 1, j - 1 )
    end
  end
  love.graphics.setCanvas()
  return w
end

function World:draw()
  love.graphics.draw(self.canvas)

end

return World
