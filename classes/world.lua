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
  w.seed = {}
  w.map = {}
  w.amplitude = {0.6, 0.3, 0.1}
  w.scale = {0.001, 0.006, 0.04}
  w.width, w.height = width, height
  w.color = {}
  w.color.dark_blue = {0, 50, 205, 255}
  w.color.light_blue = {50, 100, 255, 255}
  w.color.sand_yellow = {200, 150, 0, 255}
  w.color.light_green = {80, 100, 0, 255}
  w.color.green = {40, 100, 40, 255}
  w.color.dark_green = {30, 80, 10, 255}

  return w
end

function World:newSeed()
  self.seed[1] = math.random() * 100
  self.seed[2] = math.random() * 100
  self.seed[3] = math.random() * 100
  return self.seed
end

function World:generateAndRender(shader)
love.graphics.setShader(shader)
  base_layer = 0
  lump_layer = 0
  more_lumps = 0
  -- Create the Height Map
  for i = 1, self.width do
      self.map[i] = {}
      for j = 1, self.height do
        base_layer = self.amplitude[1] * love.math.noise(self.scale[1] * i + self.seed[1], self.scale[1] * j + self.seed[1])
        lump_layer = self.amplitude[2] * love.math.noise(self.scale[2] * i + self.seed[2], self.scale[2] * j + self.seed[2])
        more_lumps = self.amplitude[3] * love.math.noise(self.scale[3] * i + self.seed[3], self.scale[3] * j + self.seed[3])
        self.map[i][j] = base_layer + lump_layer + more_lumps
      end
  end
  -- Draw the Height Map to a canvas
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  love.graphics.setCanvas(self.canvas)
  -- Render Base Image
  for i = 1, self.width do
    for j = 1, self.height do
      if self.map[i][j] < 0.15 then
        love.graphics.setColor(self.color.dark_blue)
      elseif self.map[i][j] < 0.28 then
        love.graphics.setColor(self.color.light_blue)
      elseif self.map[i][j] < 0.33 then
        love.graphics.setColor(self.color.sand_yellow)
      elseif self.map[i][j] < 0.5 then
        love.graphics.setColor(self.color.light_green)
      elseif self.map[i][j] < 0.8 then
        love.graphics.setColor(self.color.green)
      else
        love.graphics.setColor(self.color.dark_green)
      end
      love.graphics.point( i - 1, j - 1 )
    end
  end
  love.graphics.setCanvas()
  love.graphics.setShader()
end

function World:draw()
  love.graphics.draw(self.canvas)
end

return World
