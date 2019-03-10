-- Welcome to your new Castle project!
-- https://playcastle.io/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/

if CASTLE_PREFETCH then
 CASTLE_PREFETCH({
   'main.lua',
   'src/game.lua',
   'src/generateLevel.lua',
   'src/constants.lua',
   'src/entity/Entity.lua',
   'src/entity/Player.lua',
   'src/entity/Ball.lua',
   'src/util/createClass.lua',
   'src/util/colour.lua',
   'src/util/collision.lua',
   'src/util/gfx.lua',
   'src/util/list.lua',
   'src/util/sounds.lua',
   'src/util/sound.lua',
   'src/util/SpriteSheet.lua',
   'assets/img/game-ui.png',
   'assets/img/player.png',
   'assets/img/ball.png',
   'assets/saxmono.ttf',
   'assets/snd/bounce.mp3',
   'assets/snd/ballz_moving.mp3',
   'assets/snd/beat_level.mp3',
   'assets/snd/collect.mp3',
   'assets/snd/lose_life.mp3'
 })
end

local constants = require 'src/constants'
local gfx = require 'src/util/gfx'
local game = require 'src/game'
local colour = require 'src/util/colour'

local translateScreenToCenterDx = 0
local translateScreenToCenterDy = 0

function love.load()
 -- initialise and update the gfx display
 gfx:init()
 gfx:updateDisplay()
 print("game res:    "..constants.GAME_WIDTH..","..constants.GAME_HEIGHT)
 local win_w,win_h=love.graphics.getDimensions()
 print("window size: "..win_w..","..win_h)

 -- make default mouse invisible
 love.mouse.setVisible(false) 

 game.load()
end

function love.update(dt)
 game.update(dt)
end

function love.draw()
 -- Center everything within Castle window
 love.graphics.push()
 translateScreenToCenterDx = 0.5 * (love.graphics.getWidth() - gfx.SCREEN_WIDTH)
 translateScreenToCenterDy = 0.5 * (love.graphics.getHeight() - gfx.SCREEN_HEIGHT)
 love.graphics.translate(translateScreenToCenterDx, translateScreenToCenterDy)
 -- Set "Point/Non-AA" Filters for...
 love.graphics.setDefaultFilter('nearest', 'nearest') -- Sprites (Quads)
 love.graphics.setLineStyle("rough")                  -- Shapes (Circles, Lines...)
 love.graphics.setPointSize(gfx.RENDER_SCALE)         -- Single dots
 -- Apply camera transformations
 love.graphics.translate(gfx.RENDER_X, gfx.RENDER_Y)
 --love.graphics.scale(3, 3)
 love.graphics.scale(gfx.RENDER_SCALE, gfx.RENDER_SCALE)

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

-- Force recalc of render dimensions on resize
-- (especially on Fullscreen switch)
function love.resize(w,h)
 gfx:updateDisplay()
end
