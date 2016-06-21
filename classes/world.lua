-- World Class
local World = {}
World.__index = World

-- TODO: clean this - make a 'render world' method and seperate it from the creation section

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
  w.window = {}
  w.window.width, w.window.height, w.window.FLAGS = love.window.getMode()
  -- make terrain canvas thing
  w.map = {}
  for i = 1, w.window.width do
      w.map[i] = {}
      for j = 1, w.window.height do
          w.map[i][j] = love.math.noise(w.seed * i, w.seed * j)
      end
  end
  w.canvas = love.graphics.newCanvas(w.window.width, w.window.height)
  love.graphics.setCanvas(w.canvas)
  for i = 1, w.window.width do
    for j = 1, w.window.height do
      if w.map[i][j] < 0.3 then
        love.graphics.setColor(50, 100, 255, 255)
      elseif w.map[i][j] < 0.35 then
        love.graphics.setColor(200, 150, 0, 255)
      elseif w.map[i][j] < 0.5 then
        love.graphics.setColor(80, 100, 0, 255)
      elseif w.map[i][j] < 0.9 then
        love.graphics.setColor(40, 100, 40, 255)
      else
        love.graphics.setColor(30, 80, 10, 255)
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
