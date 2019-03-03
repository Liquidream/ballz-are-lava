-- Welcome to your new Castle project!
-- https://playcastle.io/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/

if CASTLE_PREFETCH then
 CASTLE_PREFETCH({
   'main.lua',
   'src/game.lua',
   'src/constants.lua',
   'src/entity/Entity.lua',
   'src/util/createClass.lua',
   'src/util/colour.lua',
   'img/player.png',
 })
end

local constants = require 'src/constants'
local game = require 'src/game'
local colour = require 'src/util/colour'

local translateScreenToCenterDx = 0
local translateScreenToCenterDy = 0

function love.load()
 print("game res:    "..constants.GAME_WIDTH..","..constants.GAME_HEIGHT)
 local win_w,win_h=love.graphics.getDimensions()
 print("window size: "..win_w..","..win_h)
 -- force "point" scaling
 --love.graphics.setDefaultFilter('nearest', 'nearest', 0)

 game.load()
end

function love.update(dt)
 game.update(dt)
end

function love.draw()
 -- Center everything within Castle window
 love.graphics.push()
 translateScreenToCenterDx = 0.5 * (love.graphics.getWidth() - constants.SCREEN_WIDTH)
 translateScreenToCenterDy = 0.5 * (love.graphics.getHeight() - constants.SCREEN_HEIGHT)
 love.graphics.translate(translateScreenToCenterDx, translateScreenToCenterDy)
 -- Set Filter
 love.graphics.setDefaultFilter('nearest', 'nearest')
 -- Apply camera transformations
 love.graphics.translate(constants.RENDER_X, constants.RENDER_Y)
 --love.graphics.scale(3, 3)
 love.graphics.scale(constants.RENDER_SCALE, constants.RENDER_SCALE)

 game.draw()

-- Draw blinders
love.graphics.setColor(0, 0, 0, 1)
love.graphics.rectangle('fill', constants.GAME_RIGHT, constants.GAME_TOP - 1000, 1000, constants.GAME_HEIGHT + 2000)
love.graphics.rectangle('fill', constants.GAME_LEFT - 1000, constants.GAME_TOP - 1000, 1000, constants.GAME_HEIGHT + 2000)
love.graphics.rectangle('fill', constants.GAME_LEFT - 1000, constants.GAME_TOP - 1000, constants.GAME_WIDTH + 2000, 1000)
love.graphics.rectangle('fill', constants.GAME_LEFT - 1000, constants.GAME_BOTTOM, constants.GAME_WIDTH + 2000, 1000)

-- Draw game bounds
-- love.graphics.setColor(colour[17])
-- love.graphics.rectangle('line', 0, 0, constants.GAME_WIDTH, constants.GAME_HEIGHT)


 -- Pop centering within Castle window 
 -- (and restore 100% scale state)
 love.graphics.pop()

 -- Draw screen bounds
-- love.graphics.setColor(0, 1, 0, 1)
-- love.graphics.rectangle('line', 0, 0, constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT)

end


-- ------------------------------------------------

-- Constants
-- local GAME_WIDTH = 320  -- 16:9 aspect
-- local GAME_HEIGHT = 180
-- local RENDER_SCALE = 3

-- Game vars
local total_time_elapsed = 0

-- helper function
-- function fromRGB(red, green, blue) -- alpha?
--  return {red/255, green/255, blue/255}
-- end


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

