-- Manage the render state and options

local constants = require 'src/constants'




-- Screen dimensions are hardware-based (what's the size of the display device)
local SCREEN_WIDTH
local SCREEN_HEIGHT


-- Render dimenisions reflect how the game should be drawn to the canvas
--local RENDER_SCALE = 2
local RENDER_SCALE
local RENDER_WIDTH
local RENDER_HEIGHT
local RENDER_X
local RENDER_Y


local function updateDisplay(self)
 -- Screen dimensions are hardware-based (what's the size of the display device)
 local width, height = love.graphics.getDimensions()
 self.SCREEN_WIDTH = width
 self.SCREEN_HEIGHT = height
 self.RENDER_SCALE = math.floor(math.min(self.SCREEN_WIDTH / constants.GAME_WIDTH, self.SCREEN_HEIGHT / constants.GAME_HEIGHT))
 self.RENDER_WIDTH = self.RENDER_SCALE * constants.GAME_WIDTH
 self.RENDER_HEIGHT = self.RENDER_SCALE * constants.GAME_HEIGHT
 self.RENDER_X = (self.SCREEN_WIDTH - self.RENDER_WIDTH) / 2
 self.RENDER_Y = (self.SCREEN_HEIGHT - self.RENDER_HEIGHT) / 2
end

return {
 
 SCREEN_WIDTH = SCREEN_WIDTH,
 SCREEN_HEIGHT = SCREEN_HEIGHT,
 RENDER_SCALE = RENDER_SCALE,
 RENDER_WIDTH = RENDER_WIDTH,
 RENDER_HEIGHT = RENDER_HEIGHT,
 RENDER_X = RENDER_X,
 RENDER_Y = RENDER_Y,

 updateDisplay = updateDisplay,
}