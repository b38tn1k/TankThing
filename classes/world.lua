-- World Class
-- need to change world generateion to remove overscaling. just use 1:1
-- scale with the perlin map. this should make it faster/remove complexity
local World = {}
World.__index = World


function World.create(width, height, screen_width, screen_height, resolution)
  local w = {}
  setmetatable(w, World)
  w.seed = {}
  w.map = {}
  w.amplitude = {0.6, 0.3, 0.04}
  w.scale = {0.005, 0.01, 0.1}
  -- w.scale = {0.001, 0.006, 0.03}
  w.width, w.height = width, height
  w.screen_width, w.screen_height = screen_width, screen_height
  w.offset = {}
  w.offset.y, w.offset.x = 0, 0
  w.biomes = {}
  plains = {}
  plains.deep_water = {90, 203, 243, 255}
  plains.shallow_water = {152, 218, 246, 255}
  plains.beach = {214, 205, 170, 255}
  plains.low_land = {153, 172, 128, 255}
  plains.mid_land = {137, 166, 107, 255}
  plains.hills = {88, 132, 112, 255}
  table.insert(w.biomes, plains)
  desert = {}
  desert.deep_water = {90, 203, 243, 255}
  desert.shallow_water = {152, 218, 246, 255}
  desert.beach = {119, 136, 152, 255}
  desert.low_land = {255, 221, 85, 255}
  desert.mid_land = {255, 119, 35, 255}
  desert.hills = {204, 85, 51, 255}
  table.insert(w.biomes, desert)
  w.deep_water = 0.15
  w.shallow_water = 0.28
  w.beach = 0.33
  w.low_land = 0.5
  w.mid_land = 0.7
  w.traversable = w.beach
  w.path_map = {}
  w.resolution = resolution
  return w
end

function World:newSeed()
  self.seed[1] = math.random() * 100
  self.seed[2] = math.random() * 100
  self.seed[3] = math.random() * 100
  return self.seed
end

function World:makeHeightMap()
  base_layer = 0
  lump_layer = 0
  more_lumps = 0
  for i = 1, math.ceil((self.width + 1)/self.resolution) do
    self.map[i] = {}
    for j = 1, math.ceil((self.height + 1)/self.resolution) do
      base_layer = self.amplitude[1] * love.math.noise(self.scale[1] * i + self.seed[1], self.scale[1] * j + self.seed[1])
      lump_layer = self.amplitude[2] * love.math.noise(self.scale[2] * i + self.seed[2], self.scale[2] * j + self.seed[2])
      more_lumps = self.amplitude[3] * love.math.noise(self.scale[3] * i + self.seed[3], self.scale[3] * j + self.seed[3])
      self.map[i][j] = base_layer + lump_layer + more_lumps
    end
  end
end

function World:makePathMap()
  for i = 1, math.ceil((self.width + 1)/self.resolution) do
    for j = 1, math.ceil((self.height + 1)/self.resolution) do
      node = {}
      node.x = i
      node.y = j
      if self.map[i][j] > self.traversable then
        table.insert(self.path_map, node)
      end
    end
  end
end

function World:generate()
  self.path_map = {}
  self:makeHeightMap()
  self:makePathMap()
  -- self.path_map = combineMaps(findBiggestIsland(self.path_map), findBiggestIsland(reverseMap(self.path_map)))
  return self.path_map
end

function combineMaps(mapa, mapb)
  local new_map = mapa
  for _, node in ipairs(mapb) do
    if not nodeInSet(node, new_map) then
      table.insert(new_map, node)
    end
  end
  return new_map
end

function reverseMap(map)
  local reversed = {}
  for i  = #map, 1, -1 do
    table.insert(reversed, map[i])
  end
  return reversed
end

function findBiggestIsland(map)
  local lumps = {{map[1]}}  --lumps are islands, but lumps sounds cuter
  for i, node in ipairs(map) do
    local in_lump = false
    local the_lump = 1
    for j, lump in ipairs(lumps) do
      if nodeInSet(node, lump) then
        in_lump = true
        the_lump = j
        break
      else
        in_lump = false
      end
    end
    neighbours_of_node = findNeighbours(node, map)
    if in_lump == true then
      for _, neighbour in ipairs(neighbours_of_node) do
        if not nodeInSet(neighbour, lumps[the_lump]) then
          table.insert(lumps[the_lump], neighbour)
        end
      end
    else
      local new_lump = {}
      for _, neighbour in ipairs(neighbours_of_node) do
        table.insert(new_lump, neighbour)
      end
      table.insert(lumps, new_lump)
    end
  end

-- join neighbouring lumps here

  local cleaned_map = {}
  for i, lump in ipairs(lumps) do
    if #lump > #cleaned_map then
      cleaned_map = lump
    end
  end
  return cleaned_map
end

function combineSets(seta, setb)
  local new_set = {}
  for _, i in ipairs(seta) do
    table.insert(new_set, i)
  end
  for _, i in ipairs(setb) do
    table.insert(new_set, i)
  end
  return new_set
end

function getAverageValue(map, x, y, radius, height, width)
  culminator = 0
  if x < math.ceil(radius/2) or y < math.ceil(radius/2) then
    radius = math.min (x, y)
  end
  if width - x < math.ceil(radius/2) or height - y < math.ceil(radius/2) then
    radius = math.min (width - x, height - y)
  end
  for i = (x - math.floor(radius/2)), (x + math.floor(radius/2)) do
    for j = (y - math.floor(radius/2)), (y + math.floor(radius/2)) do
      culminator = culminator + map[i][j]
    end
  end
  culminator = culminator / (radius * radius)
  return culminator
end

function World:makeCanvas(biome)
  -- Draw the Height Map to a canvas
  self.canvas = lg.newCanvas(self.width, self.height)
  lg.setCanvas(self.canvas)
  colors = {}
  local setColor = lg.setColor
  local rectangle = lg.rectangle
  -- Render Base Image
  for i = 1, math.ceil((self.width + 1)/self.resolution) do
    for j = 1, math.ceil((self.height + 1)/self.resolution) do
      if self.map[i][j] < self.deep_water then
        color = mixColors(self.biomes[biome].deep_water, self.biomes[biome].deep_water, self.map[i][j], self.deep_water, 0.0)
        setColor(color)
      elseif self.map[i][j] < self.shallow_water then
        color = mixColors(self.biomes[biome].deep_water, self.biomes[biome].shallow_water, self.map[i][j], self.shallow_water, self.deep_water)
        setColor(color)
      elseif self.map[i][j] < self.beach then
        color = mixColors(self.biomes[biome].shallow_water, self.biomes[biome].beach, self.map[i][j], self.beach, self.shallow_water)
        setColor(color)
      elseif self.map[i][j] < self.low_land then
        color = mixColors(self.biomes[biome].beach, self.biomes[biome].low_land, self.map[i][j], self.low_land, self.beach)
        setColor(color)
      elseif self.map[i][j] < self.mid_land then
        color = mixColors(self.biomes[biome].low_land, self.biomes[biome].mid_land, self.map[i][j], self.mid_land, self.low_land)
        setColor(color)
      else
        color = mixColors(self.biomes[biome].mid_land, self.biomes[biome].hills, self.map[i][j], 1.0, self.mid_land)
        setColor(color)
      end
      -- lg.point( i - 1, j - 1 )
      rectangle("fill", self.resolution * (i-1), self.resolution * (j-1), self.resolution, self.resolution)
    end
  end
  lg.setCanvas()
end

function World:drawDebug()
  lg.setColor(200, 0, 255, 255)
  for i, node in ipairs(self.path_map) do
    lg.rectangle("fill", node.x * self.resolution , node.y * self.resolution, 2, 2)
  end
end


function mixColors(color1, color2, val, max, min)
  new_color = {0, 0, 0, 255}
  denominator = max - min
  numerator = val - min
  mix_colors_ratio = numerator / denominator
  complement = 1 - mix_colors_ratio
  new_color[1] = (color2[1]* mix_colors_ratio + color1[1] * complement)
  new_color[2] = (color2[2]* mix_colors_ratio + color1[2] * complement)
  new_color[3] = (color2[3]* mix_colors_ratio + color1[3] * complement)
  return new_color
end

function World:draw()
  lg.draw(self.canvas, self.offset.x, self.offset.y)
end

function World:update()
  if love.keyboard.isDown("s") then
    self.offset.y = self.offset.y - self.resolution
  end
  if love.keyboard.isDown("w") then
    self.offset.y = self.offset.y + self.resolution
  end
  if love.keyboard.isDown("d") then
    self.offset.x = self.offset.x - self.resolution
  end
  if love.keyboard.isDown("a") then
    self.offset.x = self.offset.x + self.resolution
  end
  if self.offset.y > 0 then
    self.offset.y = 0
  elseif self.offset.y < self.screen_height - self.height then
    self.offset.y = self.screen_height - self.height
  end
  if self.offset.x < self.screen_width - self.width then
    self.offset.x = self.screen_width - self.width
  elseif self.offset.x > 0 then
      self.offset.x = 0
  end
end
return World
