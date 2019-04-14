
-- This file is used only when running the game directly in LOVE

local constants = require 'src/constants'  

function love.conf(t)
  local scale=3
  -- The window width (number)
  t.window.width = constants.GAME_WIDTH*scale
  -- The window height (number)
  t.window.height = constants.GAME_HEIGHT*scale
  -- Remove all border visuals from t
  t.window.borderless = false
end