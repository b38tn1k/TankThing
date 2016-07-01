local Menu = {}
Menu.__index = Menu

function Menu.create(width, height, tank_imgs, logo)
  local m = {}
  setmetatable(m, Menu)
  m.screen_width = width
  m.screen_height = height
  m.border = 20
  m.width = m.screen_width - 2 * m.border
  m.height = m.screen_height - 2 * m.border
  m.logo = love.graphics.newImage(logo)
  m.tank_logos = {}
  for _, images in ipairs(tank_imgs) do
    base_image = love.graphics.newImage(images[2])
    turrent_image = love.graphics.newImage(images[3])
    new_tank_logo = {base_image, turrent_image}
    table.insert(m.tank_logos, new_tank_logo)
  end
  m.tank_button_dims = {}
  m.new_game_button_dims = {m.screen_width / 2 - m.logo:getWidth()/2, m.screen_width / 2 + m.logo:getWidth()/2, m.border * 2, m.border * 2 + m.logo:getHeight()}
  return m
end

function Menu:draw()
  -- DRAW BACKGROUND
  love.graphics.setColor(255, 255, 255, 150)
  love.graphics.rectangle("fill", self.border, self.border, self.width, self.height)
  love.graphics.reset()
  -- DRAW LOGO
  love.graphics.draw(self.logo, self.new_game_button_dims[1], self.new_game_button_dims[3], 0, 1, 1)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.print("Click TANKS for NEW GAME\nESC to Pause/Continue\nTAB for Debug Mode\nControl Tanks with Mouse or Active Tanke with WASD + SPACE", self.border*2, self.border * 4 + self.logo:getHeight())
  -- DRAW TANKS
  -- y = self.border * 5 + self.logo:getHeight()
  -- for i, tank in ipairs(self.tank_logos) do
  --   x = self.border + (i - 1) * (self.width / #self.tank_logos) + (self.width / #self.tank_logos) /2
  --   love.graphics.draw(tank[1], x, y, 0, 1, 1, tank[1]:getWidth()/2, tank[1]:getHeight()/2)
  --   love.graphics.draw(tank[2], x, y, 0, 1, 1, tank[2]:getWidth()/2, tank[2]:getHeight()/2)
  --   local new_button = {x, y, tank[1]:getWidth(), tank[1]:getHeight()}
  --   table.insert(self.tank_button_dims, new_button)
  -- end
end

function Menu:new_game_button(x, y)
  dims = self.new_game_button_dims
  return x > dims[1] and x < dims[2] and y > dims[3] and y < dims[4]
end

return Menu
