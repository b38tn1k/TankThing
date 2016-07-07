local Menu = {}
Menu.__index = Menu

function Menu.create(width, height, assets)
  local m = {}
  setmetatable(m, Menu)
  m.screen_width = width
  m.screen_height = height
  m.border = 20
  m.width = m.screen_width - 2 * m.border
  m.height = m.screen_height - 2 * m.border
  m.logo = lg.newImage(assets.logo)
  m.new_game_button_dims = {m.screen_width / 2 - m.logo:getWidth()/2, m.screen_width / 2 + m.logo:getWidth()/2, m.border * 2, m.border * 2 + m.logo:getHeight()}
  return m
end

function Menu:draw()
  -- DRAW BACKGROUND
  lg.setColor(255, 255, 255, 150)
  lg.rectangle("fill", self.border, self.border, self.width, self.height)
  lg.reset()
  -- DRAW LOGO
  lg.draw(self.logo, self.new_game_button_dims[1], self.new_game_button_dims[3], 0, 1, 1)
  lg.setColor(0, 0, 0, 255)
  lg.print("Click TANKS for NEW GAME\nESC to Pause/Continue\nTAB for Debug Mode\nControl Tanks with Mouse or Active Tank with WASD + SPACE", self.border*2, self.border * 4 + self.logo:getHeight())
end

function Menu:new_game_button(x, y)
  dims = self.new_game_button_dims
  return x > dims[1] and x < dims[2] and y > dims[3] and y < dims[4]
end

return Menu
