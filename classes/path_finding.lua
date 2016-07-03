function clean_path(path, map)
  -- takes the path throguh the map
  local cleaned = {}
  local neighbours = {}
  local overlaps = {}
  length = #path
  local latch = 0
  -- go through every node in the path
  for i, node in ipairs(path) do
    neighbours = find_neighbours(node, map)
    for j = (length), i + 2, -1 do
      -- go from last node in the path back to the current node
      -- find overlaping/looping sections, but only the biggest ones
      if i > latch and node_in_set(path[j], neighbours) then
        table.insert(overlaps, {i, j})
        latch = j
      end
    end
  end
  for i, node in ipairs(path) do
    if not_in_ranges(i, overlaps) then
      table.insert(cleaned, node)
    end
  end
  return cleaned
end

function not_in_ranges(i, ranges)
  result = true
  for _, range in ipairs(ranges) do
    if i > range[1] and i < range[2] then
      result = false
    end
  end
  return result
end

function node_in_set(node, set)
  result = false
  for _, a_node in ipairs(set) do
    if node.x == a_node.x and node.y == a_node.y then
      result = true
    end
  end
  return result
end

function find_node(x, y, path_map)
  local node = nil
  for i, a_node in ipairs(path_map) do
    if a_node.x == x and a_node.y == y then
      node = a_node
    end
  end
  return node
end

-- Find Neighbouring nodes in the path_map
function find_neighbours(node, path_map)
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

-- Find lazy non euclid distance
function heuristic_distance(a, b)
  return ((b.x - a.x) * (b.x - a.x)) + ((b.y - a.y) * (b.y - a.y))
end

-- A* algorithim accepts start node and goal node arguements as {x_scaled, y_scaled} and path_map as a path_map
function Astar(start, goal, path_map)
  local open = {}
  local closed = {}
  start.g = 0
  start.h = heuristic_distance(start, goal)
  start.f = start.g + start.h
  table.insert(open, start)
  while not(next(open) == nil) do
    -- find node with smallest f!
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
    for j, neighbour in ipairs(find_neighbours(q, path_map)) do
      if neighbour.x == goal.x and neighbour.y == goal.y then
        open = {}
        break
      end
      neighbour.g = q.g + heuristic_distance(neighbour, q)
      neighbour.h = heuristic_distance(neighbour, goal)
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
  end
  cleaned_closed = clean_path(closed, path_map)
  return cleaned_closed
end
