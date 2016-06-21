-- World Class
local w = {}

w.time = 0
w.window = {}

local function init()
  w.window.width, w.window.height, w.window.FLAGS = love.window.getMode()
end
w.init = init

return w
