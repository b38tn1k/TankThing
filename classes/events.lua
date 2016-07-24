function love.mousepressed(x, y, button, istouch)
  if game.pause == true then
    -- NEW GAME BUTTON
    if game.menu:newGameButton(x, y) == true then
      game.screen.width, game.screen.height = love.window.getDesktopDimensions(1)
      game.new()
    end
    game.menu:updateTeams(x, y)
  else
    if button == 'l' then
      game.selectTank(x, y)
    end
  end
end

function love.keyreleased(key)
  if game.pause == true then
    -- GAME MENU OPTIONS
  else
    if key == " " then
      game.fireActiveTank()
    end
    if key == "backspace" then
      game.deselectTanks()
    end
    if key == "lshift" then 
      game.playCommands()
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
  game.screen.width = w
  game.screen.height = h
  game.resize()
end

