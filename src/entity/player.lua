local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/player.png', {
  BASE = { 0, 0, 32, 32 },
  --EMPTY_HEART = { 133, 101, 11, 10 }
})

local Player = Entity.extend({
 size = 0.25, -- 0..1 (scale)
 radius = 15,
 -- width = constants.CARD_WIDTH,
 -- height = constants.CARD_HEIGHT,

constructor = function(self)
  Entity.constructor(self)
  -- self.colorIndex = self.suitIndex < 3 and 1 or 2
  -- self.shape = love.physics.newRectangleShape(self.width, self.height)
end,
update = function(self, dt)
  -- get the position of the mouse (in game coord)
  self.x, self.y = mouseX, mouseY
  -- increase player size from start
  self.size = math.min(self.size+0.01, 0.75)--1
  -- -- Rotate
  -- if not self:animationsInclude('rotation') then
  --   self.rotation = self.rotation + self.vr * dt
  -- end
  -- -- Dilate time near the apex of a launch
  -- local timeMult = 1.0
  -- if self.canBeShot and self.gravity ~= 0.0 then
  --   timeMult = 0.9 + 1.3 * math.min(0.2 * math.abs(self.vy) / self.gravity, 1.0)
  -- end
  -- local dt2 = dt * timeMult
  -- -- Accelerate downwards
  -- self.vy = self.vy + self.gravity * dt2
  -- Entity.update(self, dt2)
  -- -- Fall offscreen
  -- if self.y > constants.GAME_HEIGHT + constants.CARD_HEIGHT then
  --   self:die()
  -- end
end,
draw = function(self)
 local x = self.x
 local y = self.y
 -- local w = self.width / 2
 -- local h = self.height / 2
 
 -- love.graphics.setColor(255, 0, 0)
 -- love.graphics.circle("fill", self.x, self.y, 25)

 love.graphics.setColor(1, 1, 1)
 local sprite = 'BASE'
 SPRITESHEET:drawCentered(sprite, self.x, self.y, nil, nil, nil, self.size, self.size)

end,
})

return Player