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
   'src/scenes.lua',
   'src/entity/Entity.lua',
   'src/entity/Player.lua',
   'src/entity/Ball.lua',
   'src/entity/PowerUp.lua',
   'src/util/createClass.lua',
   'src/util/colour.lua',
   'src/util/collision.lua',
   'src/util/controller.lua',
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
  --This sets the draw target to the canvas
  love.graphics.setCanvas(gfx.RENDER_CANVAS)

  -- Camera translatons (Shake)
  love.graphics.push()
  
    -- Set "Point/Non-AA" Filters for...
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Sprites (Quads)
    love.graphics.setLineStyle("rough")                  -- Shapes (Circles, Lines...)

    -- Apply camera transformations
    love.graphics.translate(gfx.shakeX, gfx.shakeY)

    game.draw()

    -- Draw game bounds
    -- love.graphics.setColor(colour[17])
    -- love.graphics.rectangle('line', 0, 0, constants.GAME_WIDTH, constants.GAME_HEIGHT)

  -- Pop camera translations (Shake)
  love.graphics.pop()

  -- Draw the canvas, scaled, to screen
  love.graphics.setCanvas() --This sets the target back to the screen

  -- Center everything within Castle window
  love.graphics.push()
    
    -- Apply "Center to Window" transformations
    love.graphics.translate(gfx.RENDER_X, gfx.RENDER_Y)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gfx.RENDER_CANVAS, 0, 0, 0, gfx.RENDER_SCALE, gfx.RENDER_SCALE)

  -- Pop centering within Castle window
  love.graphics.pop()

  -- Draw screen bounds
  -- love.graphics.setColor(0, 1, 0, 1)
  -- love.graphics.rectangle('line', 0, 0, gfx.SCREEN_WIDTH, gfx.SCREEN_HEIGHT)

end

-- Force recalc of render dimensions on resize
-- (especially on Fullscreen switch)
function love.resize(w,h)
 gfx:updateDisplay()
end
