function cleanPath(path, map)
  -- takes the path throguh the map
  local cleaned = {}
  local neighbours = {}
  local overlaps = {}
  length = #path
  local latch = 0
  -- go through every node in the path
  for i, node in ipairs(path) do
    neighbours = findNeighbours(node, map)
    for j = (length), i + 2, -1 do
      -- go from last node in the path back to the current node
      -- find overlaping/looping sections, but only the biggest ones
      if i > latch and nodeInSet(path[j], neighbours) then
        table.insert(overlaps, {i, j})
        latch = j
      end
    end
  end
  for i, node in ipairs(path) do
    if notInRanges(i, overlaps) then
      table.insert(cleaned, node)
    end
  end
  return cleaned
end

function notInRanges(i, ranges)
  result = true
  for _, range in ipairs(ranges) do
    if i > range[1] and i < range[2] then
      result = false
    end
  end
  return result
end

function nodeInSet(node, set)
  result = false
  for _, a_node in ipairs(set) do
    if node.x == a_node.x and node.y == a_node.y then
      result = true
    end
  end
  return result
end

function findNode(x, y, path_map)
  local node = nil
  for i, a_node in ipairs(path_map) do
    if a_node.x == x and a_node.y == y then
      node = a_node
    end
  end
  return node
end

-- Find Neighbouring nodes in the path_map
function findNeighbours(node, path_map)
  local neighbours = {}
  local y = node.y
  local x = node.x
  for _, a_node in ipairs(path_map) do
    if (a_node.x == x or a_node.x == x - 1 or a_node.x == x + 1) and (a_node.y == y or a_node.y == y + 1 or a_node.y == y - 1) and not (a_node.x == x and a_node.y == y) then
      table.insert(neighbours, a_node)
    end
  end
  return neighbours
end

function findMoreNeighbours(node, map, size, distance)
  local neighbours = findAlmostNeighbours(node, map, distance)
  while size ~= 0 do
    local nb = {}
    for _, neighbour in ipairs(neighbours) do
      nb = findAlmostNeighbours(neighbour, map, distance)
      neighbours = combineMaps(nb, neighbours)
    end
    size = size - 1
  end
  return neighbours
end

function findAlmostNeighbours(node, map, distance)
  local neighbours = {}
  local y = node.y
  local x = node.x
  for _, a_node in ipairs(map) do
    if (a_node.x == x or a_node.x == x - distance or a_node.x == x + distance) and (a_node.y == y or a_node.y == y + distance or a_node.y == y - distance) and not (a_node.x == x and a_node.y == y) then
      table.insert(neighbours, a_node)
    end
  end
  return neighbours
end

-- Find lazy non euclid distance
function heuristicDistance(a, b)
  return ((b.x - a.x) * (b.x - a.x)) + ((b.y - a.y) * (b.y - a.y))
end

-- A* algorithim accepts start node and goal node arguements as {x_scaled, y_scaled} and path_map as a path_map
function Astar(start, goal, path_map)
  local open = {}
  local closed = {}
  local counter = 0 --use to escape larger path finding
  start.g = 0
  start.h = heuristicDistance(start, goal)
  start.f = start.g + start.h
  table.insert(open, start)
  while not(next(open) == nil) do
    -- find node with smallest f!
    counter = counter + 1
    to_remove = 1
    q = open[to_remove]
    for i, node in ipairs(open) do
      if node.f < q.f then
        q = node
        to_remove = i
      end
    end
    table.remove(open, to_remove)
    -- find the neighbours of q and set them up
    for j, neighbour in ipairs(findNeighbours(q, path_map)) do
      if neighbour.x == goal.x and neighbour.y == goal.y then
        open = {}
        break
      end
      neighbour.g = q.g + heuristicDistance(neighbour, q)
      neighbour.h = heuristicDistance(neighbour, goal)
      neighbour.f = neighbour.g + neighbour.h
      -- check for duplicates in open and closed lists
      local add = true
      for _, a_node in ipairs(open) do
        if neighbour.x == a_node.x and neighbour.y == a_node.y then
          add = false
        end
      end
      for _, a_node in ipairs(closed) do
        if neighbour.x == a_node.x and neighbour.y == a_node.y then
          add = false
        end
      end
      if add == true then
        table.insert(open, neighbour)
      end
    end
    -- add q to the closed list
    table.insert(closed, q)
    if counter > 500 then
      closed = {start}
      break
    end
  end
  cleaned_closed = cleanPath(closed, path_map)
  return cleaned_closed
end
