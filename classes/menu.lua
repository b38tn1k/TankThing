local Menu = {}
Menu.__index = Menu

function Menu.create(width, height, assets)
  local m = {}
  setmetatable(m, Menu)
  m.screen_width = width
  m.screen_height = height
  m.border = 30
  m.width = m.screen_width - 2 * m.border
  m.height = m.screen_height - 2 * m.border
  m.logo = lg.newImage(assets.logo)
  m.arrow = lg.newImage(assets.arrow)
  m.tlogos = {}
  for i, logo in ipairs(assets.small_tanks) do
    local tbase = lg.newImage(logo[2])
    local tturrent = lg.newImage(logo[3])
    local timage = lg.newCanvas(tbase:getWidth(), tturrent:getHeight())
    lg.reset()
    lg.setCanvas(timage)
    lg.draw(tbase, 0, tturrent:getHeight() / 2 -tbase:getHeight() / 2)
    lg.draw(tturrent, tbase:getWidth() / 2 - tturrent:getWidth() / 2, 0)
    lg.setCanvas()
    table.insert(m.tlogos, timage)
  end
  m.ngbutton_dims = {m.screen_width / 2 - m.logo:getWidth()/2, m.screen_width / 2 + m.logo:getWidth()/2, m.border, m.border + m.logo:getHeight()}
  m.tank_buttons = {}
  m.max_team_size = 5
  m.team_sizes = {5, 5, 5, 5}
  m.tank_logo_height = m.tlogos[1]:getHeight()
  m.tank_logo_width = m.tlogos[1]:getWidth()
  m.player_team = 1
  m.tank_start_y = m.border + m.logo:getHeight()
  m.tank_start_x = (m.screen_width - m.max_team_size * (m.tank_logo_width + m.border))/2 + m.border
  return m
end

function Menu:update()
  self.tank_buttons = {}
  local button = {}
  for i, count in ipairs(self.team_sizes) do
    button = {}
    button.delineator = self.tank_start_x + (count + 1) * self.border
    button.min_y = self.tank_start_y + i * self.tank_logo_height
    button.max_y = self.tank_start_y + (i + 1) * self.tank_logo_height
    table.insert(self.tank_buttons, button)
  end
end

function Menu:draw()
  -- DRAW BACKGROUND
  lg.setColor(255, 255, 255, 150)
  lg.rectangle("fill", self.border, self.border, self.width, self.height)
  lg.setColor(255, 100, 255, 255)
  lg.printf("CLICK ON THE LOGO TO PLAY!", self.ngbutton_dims[1], self.ngbutton_dims[3] + self.logo:getHeight(), self.logo:getWidth(), "center")
  lg.reset()
  -- DRAW LOGO/NEW GAME BUTTON
  lg.draw(self.logo, self.ngbutton_dims[1], self.ngbutton_dims[3], 0, 1, 1)
  -- DRAW TANKS AND TEAM SELECTION
  for i, team in ipairs(self.team_sizes) do -- for every team
    if i == self.player_team then 
      lg.setColor(255, 100, 255, 255)
      -- lg.draw(self.arrow, self.tank_start_x - self.border, self.tank_start_y + i * self.tank_logo_height)
      lg.printf("YOUR TEAM:", self.tank_start_x - self.border*2, self.tank_logo_height / 4 + self.tank_start_y + i * self.tank_logo_height, 100, "left")
      lg.reset()
    end
    for j = 1, team do -- for every team member
      local xpos = self.tank_start_x + self.border * j
      local ypos = self.tank_start_y + i * self.tank_logo_height
      lg.draw(self.tlogos[i], xpos, ypos)
    end
  end
end

function Menu:newGameButton(x, y)
  dims = self.ngbutton_dims
  return x > dims[1] and x < dims[2] and y > dims[3] and y < dims[4]
end

function Menu:updateTeams(x, y)
  for i, button in ipairs(self.tank_buttons) do
    if y > button.min_y and y < button.max_y then
      if x > button.delineator then
        if self.team_sizes[i] < self.max_team_size then
          self.team_sizes[i] = self.team_sizes[i] + 1
        end
      elseif x > self.tank_start_x + self.border then 
          self.team_sizes[i] = self.team_sizes[i] - 1
      else 
        self.player_team = i
      end
    end
  end
end

return Menu
