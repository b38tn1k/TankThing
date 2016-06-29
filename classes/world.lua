-- World Class
local World = {}
World.__index = World

-- TODO: clean this - make a 'render world' method and seperate it from the creation section

function World.create(width, height, occupancy_resolution, render_resolution)
  local w = {}
  setmetatable(w, World)
  math.randomseed(os.time() * 1000)
  for i = 1, 100 do   -- clear out start of random buffer
    math.random()
  end
  w.seed = {}
  w.map = {}
  w.amplitude = {0.6, 0.3, 0.05}
  w.scale = {0.001, 0.006, 0.04}
  w.width, w.height = width, height
  w.color = {}
  w.color.dark_blue = {90, 203, 243, 255} --rgb(90, 203, 243)
  w.color.light_blue = {152, 218, 246, 255} --rgb(152, 218, 246)
  w.color.sand_yellow = {214, 205, 170, 255} --rgb(214, 205, 170)
  w.color.light_green = {153, 172, 128, 255} --rgb(153, 172, 128)
  w.color.green = {137, 166, 107, 255} --rgb(137, 166, 107)
  w.color.dark_green = {88, 132, 112, 255} --rgb(88, 132, 112)
  w.deep_water = 0.15
  w.shallow_water = 0.28
  w.beach = 0.33
  w.low_land = 0.5
  w.mid_land = 0.7
  w.traversable = (w.low_land + w.beach)/2
  w.occupancy_grid = {}
  w.occupancy_resolution = occupancy_resolution
  w.render_resolution = render_resolution

  return w
end

function World:newSeed()
  self.seed[1] = math.random() * 100
  self.seed[2] = math.random() * 100
  self.seed[3] = math.random() * 100
  return self.seed
end

function World:generate()
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
  -- Create the low res Occupancy Grid
  for i = 1, self.width, self.occupancy_resolution do
    x = (i + self.occupancy_resolution - 1) / self.occupancy_resolution
    for j = 1, self.height, self.occupancy_resolution do
      node = {}
      node.x = x
      node.y = (j + self.occupancy_resolution - 1) / self.occupancy_resolution
      if self.map[i][j] > self.traversable then
        table.insert(self.occupancy_grid, node)
      end
    end
  end
  return self.occupancy_grid
end

function World:makeCanvas(shader)
  love.graphics.setShader(shader)
  -- Draw the Height Map to a canvas
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  love.graphics.setCanvas(self.canvas)
  colors = {}
  -- Render Base Image
  for i = 1, self.width, self.render_resolution do
    for j = 1, self.height, self.render_resolution do
      if self.map[i][j] < self.deep_water then
        color = self:mix(self.color.dark_blue, self.color.dark_blue, self.map[i][j], self.deep_water, 0.0)
        love.graphics.setColor(color)
      elseif self.map[i][j] < self.shallow_water then
        color = self:mix(self.color.dark_blue, self.color.light_blue, self.map[i][j], self.shallow_water, self.deep_water)
        love.graphics.setColor(color)
      elseif self.map[i][j] < self.beach then
        color = self:mix(self.color.light_blue, self.color.sand_yellow, self.map[i][j], self.beach, self.shallow_water)
        love.graphics.setColor(color)
      elseif self.map[i][j] < self.low_land then
        color = self:mix(self.color.sand_yellow, self.color.light_green, self.map[i][j], self.low_land, self.beach)
        love.graphics.setColor(color)
      elseif self.map[i][j] < self.mid_land then
        color = self:mix(self.color.light_green, self.color.green, self.map[i][j], self.mid_land, self.low_land)
        love.graphics.setColor(color)
      else
        color = self:mix(self.color.green, self.color.dark_green, self.map[i][j], 1.0, self.mid_land)
        love.graphics.setColor(color)
      end
      -- love.graphics.point( i - 1, j - 1 )
      love.graphics.rectangle("fill", i-1, j-1, self.render_resolution, self.render_resolution)

    end
  end
  love.graphics.setCanvas()
  love.graphics.setShader()
end

function World:drawDebug()
  love.graphics.setColor(200, 200, 255, 255)
  for i = 1, self.width, self.occupancy_resolution do
    for j = 1, self.height, self.occupancy_resolution do
      if self.occupancy_grid[(i + 4) / self.occupancy_resolution][(j + 4)/self.occupancy_resolution] == 1 then
        love.graphics.rectangle("fill", i, j, 2, 2)
      end
    end
  end
end

function World:mix(color1, color2, val, max, min)
  new_color = {0, 0, 0, 255}
  denominator = max - min
  numerator = val - min
  mix_ratio = numerator / denominator
  complement = 1 - mix_ratio
  new_color[1] = (color2[1]* mix_ratio + color1[1] * complement)
  new_color[2] = (color2[2]* mix_ratio + color1[2] * complement)
  new_color[3] = (color2[3]* mix_ratio + color1[3] * complement)
  return new_color
end

function World:draw()
  love.graphics.draw(self.canvas)
end

return World
