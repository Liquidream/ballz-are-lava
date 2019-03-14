
local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'
local Sounds = require 'src/util/sounds'
local gfx = require 'src/util/gfx'
local colour = require 'src/util/colour'

local SPRITESHEET = SpriteSheet.new('assets/img/powerup.png', {
  P_1 = { 16, 0, 16, 16 }, -- SHIELD
  P_2 = { 32, 0, 16, 16 }, -- FREEZE
  P_3 = { 48, 0, 16, 16 }, -- LAVABOMB
  P_4 = { 64, 0, 16, 16 }, -- EXTRA_LIFE
  P_5 = { 72, 0, 16, 16 }, -- TIME_EXTEND
  P_6 = { 80, 0, 16, 16 }, -- INVINCIBILITY
})

local PowerUp = Entity.extend({
  size = 1, -- 0..1 (scale)
  radius = 5,
 
 constructor = function(self)
  Entity.constructor(self)
  
  self.x = love.math.random(constants.GAME_WIDTH-20)+10
  self.y = love.math.random(constants.GAME_HEIGHT-20)+10
  self.powerup_type = love.math.random(6)
  self.state = constants.POWERUP_STATE.HIDDEN
  self.frame = 1
  self.frame_delay = 0
 end,

update = function(self, dt)

  -- if game_state==constants.GAME_STATE.LVL_PLAY then
  --  -- TODO: also include PAUSE power-up
  --  -- (tho maybe better to have a factor, so can slow/speedup!)
  --  Entity.update(self, dt)
  -- end
  
  -- TODO: this!
end,

draw = function(self)
 local x = self.x 
 local y = self.y 

 local sprite = "P_"..self.powerup_type
 love.graphics.setColor(1, 1, 1)
 SPRITESHEET:drawCentered(sprite, x, y, nil, nil, nil, 1, 1)

  -- Debug collisions, etc.
  if constants.DEBUG_MODE then
    love.graphics.setColor(colour[25])
    love.graphics.circle("line", self.x, self.y, self.radius)
  end
end,
})

return PowerUp
