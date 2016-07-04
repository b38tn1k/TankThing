function love.mousepressed(x, y, button, istouch)
  if game.pause == true then
    -- NEW GAME BUTTON
    if game.menu:new_game_button(x, y) == true then
      love.graphics.clear( )
      game.screen.width, game.screen.height = love.window.getDesktopDimensions(1)
      game.new()
    end
  else
    if button == 'l' then
      game.select_tank(x, y)
    end
  end
end

function love.keyreleased(key)
  if game.pause == true then
    -- GAME MENU OPTIONS
  else
    if key == " " then
      game.fire_active_tank()
    end
  end
  -- TOGGLEABLE REGARDLESS OF GAME STATE
  if key == "escape" then
    game.pause = not game.pause
  end
  if key == 'tab' then
    game.debug = not game.debug
  end
end

function love.resize(w, h)
  love.graphics.clear()
  game.screen.width, game.screen.height = w, h
  game.resize()
end
