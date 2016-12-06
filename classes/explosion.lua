
local Explosion = {}
Explosion.__index = Explosion

function Explosion.create(frame_count, radius, resolution)
  local e = {}
  setmetatable( e, Explosion)
  e.frame_count = frame_count
  e.radius = radius
  e.resolution = resolution
  e.frames = {}
  local delta_rad = 1
  local center = radius
  for i = 1, frame_count do 
    local frame = lg.newCanvas(radius * 2, radius * 2)
    lg.setCanvas(frame)
    lg.setColor(200, 100, 0, 255)
    for x = 1, radius * 2, resolution do
      for y = 1, radius * 2, resolution do 
        local min_exp_thresh = squared(x - center) + squared(y - center)
        if min_exp_thresh < squared(radius) then
          lg.rectangle("fill", x, y, resolution, resolution)
        end
      end
    end
    lg.setCanvas()
    table.insert(e.frames, frame)
  end
  return e
end

function squared(x)
  return x * x
end

function Explosion:draw(x, y)
  lg.draw(self.frames[1], x, y)
end


return Explosion
