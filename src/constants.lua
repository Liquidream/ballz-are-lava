-- Game dimensions are display-independent (i.e. not pixel-based)
local GAME_WIDTH = 640 --320
local GAME_HEIGHT = 320 --180
local GAME_LEFT = 0
local GAME_RIGHT = GAME_WIDTH
local GAME_TOP = 0
local GAME_BOTTOM = GAME_HEIGHT
local GAME_MIDDLE_X = GAME_WIDTH / 2
local GAME_MIDDLE_Y = GAME_HEIGHT / 2

-- Screen dimensions are hardware-based (what's the size of the display device)
local width, height = love.graphics.getDimensions()
local SCREEN_WIDTH = width
local SCREEN_HEIGHT = height

-- Render dimenisions reflect how the game should be drawn to the canvas
local RENDER_SCALE = 2
--local RENDER_SCALE = math.floor(math.min(SCREEN_WIDTH / GAME_WIDTH, SCREEN_HEIGHT / GAME_HEIGHT))
local RENDER_WIDTH = RENDER_SCALE * GAME_WIDTH
local RENDER_HEIGHT = RENDER_SCALE * GAME_HEIGHT
local RENDER_X = (SCREEN_WIDTH - RENDER_WIDTH) / 2
local RENDER_Y = (SCREEN_HEIGHT - RENDER_HEIGHT) / 2

local BALL_TYPES = { 'LAVABALL', 'TARGET' }

return {
 GAME_WIDTH = GAME_WIDTH,
 GAME_HEIGHT = GAME_HEIGHT,
 GAME_LEFT = GAME_LEFT,
 GAME_RIGHT = GAME_RIGHT,
 GAME_TOP = GAME_TOP,
 GAME_BOTTOM = GAME_BOTTOM,
 GAME_MIDDLE_X = GAME_MIDDLE_X,
 GAME_MIDDLE_Y = GAME_MIDDLE_Y,
 SCREEN_WIDTH = SCREEN_WIDTH,
 SCREEN_HEIGHT = SCREEN_HEIGHT,
 RENDER_SCALE = RENDER_SCALE,
 RENDER_WIDTH = RENDER_WIDTH,
 RENDER_HEIGHT = RENDER_HEIGHT,
 RENDER_X = RENDER_X,
 RENDER_Y = RENDER_Y,
 BALL_TYPES = BALL_TYPES,
}