-- Welcome to your new Castle project!
-- https://playcastle.io/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/

if CASTLE_PREFETCH then
 CASTLE_PREFETCH({
   'main.lua',
   'src/entity/Entity.lua',
   'src/util/createClass.lua',
   'src/constants.lua',
   'src/game.lua',
   'img/player.png',
 })
end

local constants = require 'src/constants'
local game = require 'src/game'

local translateScreenToCenterDx = 0
local translateScreenToCenterDy = 0

function love.load()
 --print(constants.GAME_WIDTH)
 
 -- force "point" scaling
 --love.graphics.setDefaultFilter('nearest', 'nearest', 0)

 game.load()
end

function love.update(dt)
 game.update(dt)
end

function love.draw()
 -- Set Filter
 love.graphics.setDefaultFilter('nearest', 'nearest')
 -- Apply camera transformations
 --love.graphics.translate(constants.RENDER_X, constants.RENDER_Y)
 love.graphics.scale(3, 3)
 --love.graphics.scale(constants.RENDER_SCALE, constants.RENDER_SCALE)

 game.draw()
end


-- ------------------------------------------------

-- Constants
-- local GAME_WIDTH = 320  -- 16:9 aspect
-- local GAME_HEIGHT = 180
-- local RENDER_SCALE = 3

-- Game vars
local total_time_elapsed = 0

-- helper function
function fromRGB(red, green, blue) -- alpha?
 return {red/255, green/255, blue/255}
end


-- function love.load()
--  -- force "point" scaling
--  love.graphics.setDefaultFilter('nearest', 'nearest', 0)
  
--  -- make default mouse invisible
--  love.mouse.setVisible(false)
-- end

-- function love.draw()
--   local y_offset = 8 * math.sin(total_time_elapsed * 3)
--   love.graphics.print('Edit main.lua to get started!', 400, 300 + y_offset)
--   love.graphics.print('Press Cmd/Ctrl + R to reload.', 400, 316 + y_offset)
-- end

-- function love.update(dt)
--   total_time_elapsed = total_time_elapsed + dt
-- end

