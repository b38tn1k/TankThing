-- World Class
local World = {}
World.__index = World


function World.create(width, height, path_resolution, render_resolution)
  local w = {}
  setmetatable(w, World)
  w.seed = {}
  w.map = {}
  w.amplitude = {0.6, 0.3, 0.04}
  w.scale = {0.001, 0.006, 0.03}
  w.width, w.height = width, height
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
  w.traversable = 0.4
  w.path_map = {}
  w.path_resolution = path_resolution
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
  self.path_map = {}
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
  for i = 1, self.width, self.path_resolution do
    x = (i + self.path_resolution - 1) / self.path_resolution
    for j = 1, self.height, self.path_resolution do
      node = {}
      node.x = x
      node.y = (j + self.path_resolution - 1) / self.path_resolution
      -- could be improved to find average of terrain for more realistic mapping
      terrain_value = get_average_value(self.map, i, j, self.path_resolution, self.height, self.width)
      if terrain_value > self.traversable then
        table.insert(self.path_map, node)
      end
    end
  end
  self.path_map = combine_maps(find_biggest_island(self.path_map), find_biggest_island(reverse_map(self.path_map)))
  return self.path_map
end

function combine_maps(mapa, mapb)
  local new_map = mapa
  for _, node in ipairs(mapb) do
    if not node_in_set(node, new_map) then
      table.insert(new_map, node)
    end
  end
  return new_map
end

function reverse_map(map)
  local reversed = {}
  for i  = #map, 1, -1 do
    table.insert(reversed, map[i])
  end
  return reversed
end

function find_biggest_island(map)
  local lumps = {{map[1]}}  --lumps are islands, but lumps sounds cuter
  for i, node in ipairs(map) do
    local in_lump = false
    local the_lump = 1
    for j, lump in ipairs(lumps) do
      if node_in_set(node, lump) then
        in_lump = true
        the_lump = j
        break
      else
        in_lump = false
      end
    end
    neighbours_of_node = find_neighbours(node, map)
    if in_lump == true then
      for _, neighbour in ipairs(neighbours_of_node) do
        if not node_in_set(neighbour, lumps[the_lump]) then
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

function combine_sets(seta, setb)
  local new_set = {}
  for _, i in ipairs(seta) do
    table.insert(new_set, i)
  end
  for _, i in ipairs(setb) do
    table.insert(new_set, i)
  end
  return new_set
end

function get_average_value(map, x, y, radius, height, width)
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
  -- Render Base Image
  for i = 1, self.width, self.render_resolution do
    for j = 1, self.height, self.render_resolution do
      if self.map[i][j] < self.deep_water then
        color = mix_colors(self.biomes[biome].deep_water, self.biomes[biome].deep_water, self.map[i][j], self.deep_water, 0.0)
        lg.setColor(color)
      elseif self.map[i][j] < self.shallow_water then
        color = mix_colors(self.biomes[biome].deep_water, self.biomes[biome].shallow_water, self.map[i][j], self.shallow_water, self.deep_water)
        lg.setColor(color)
      elseif self.map[i][j] < self.beach then
        color = mix_colors(self.biomes[biome].shallow_water, self.biomes[biome].beach, self.map[i][j], self.beach, self.shallow_water)
        lg.setColor(color)
      elseif self.map[i][j] < self.low_land then
        color = mix_colors(self.biomes[biome].beach, self.biomes[biome].low_land, self.map[i][j], self.low_land, self.beach)
        lg.setColor(color)
      elseif self.map[i][j] < self.mid_land then
        color = mix_colors(self.biomes[biome].low_land, self.biomes[biome].mid_land, self.map[i][j], self.mid_land, self.low_land)
        lg.setColor(color)
      else
        color = mix_colors(self.biomes[biome].mid_land, self.biomes[biome].hills, self.map[i][j], 1.0, self.mid_land)
        lg.setColor(color)
      end
      -- lg.point( i - 1, j - 1 )
      lg.rectangle("fill", i-1, j-1, self.render_resolution, self.render_resolution)
    end
  end
  lg.setCanvas()
end

function World:imageCanvas(tiles)
  local images = {}
  for _, path in pairs(tiles) do
    new_image = lg.newImage(path)
    table.insert(images, new_image)
  end
  -- Draw the Height Map to a canvas
  self.canvas = lg.newCanvas(self.width, self.height)
  lg.setCanvas(self.canvas)
  for i = 1, self.width, self.render_resolution do
    for j = 1, self.height, self.render_resolution do
      if self.map[i][j] < self.deep_water then
        lg.draw(images[1], i, j, 0, 0.2, 0.2)
      elseif self.map[i][j] < self.shallow_water then
        lg.draw(images[2], i, j, 0, 0.2, 0.2)
      elseif self.map[i][j] < self.beach then
        lg.draw(images[3], i, j, 0, 0.2, 0.2)
      elseif self.map[i][j] < self.low_land then
        lg.draw(images[4], i, j, 0, 0.2, 0.2)
      elseif self.map[i][j] < self.mid_land then
        lg.draw(images[5], i, j, 0, 0.2, 0.2)
      else
        lg.draw(images[6], i, j, 0, 0.2, 0.2)
      end
      -- lg.point( i - 1, j - 1 )
      -- lg.rectangle("fill", i-1, j-1, self.render_resolution, self.render_resolution)
    end
  end
  lg.setCanvas()
end

function World:drawDebug()
  lg.setColor(200, 0, 255, 255)
  for i, node in ipairs(self.path_map) do
    lg.rectangle("fill", node.x * self.path_resolution , node.y * self.path_resolution, 2, 2)
  end
end


function mix_colors(color1, color2, val, max, min)
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
  lg.draw(self.canvas)
end

return World
