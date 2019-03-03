local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/lavaball.png', {
  BASE = { 0, 0, 16, 16 },
})

local Player = Entity.extend({
 size = 1, -- 0..1 (scale)

constructor = function(self)
  Entity.constructor(self, start_x, start_y, start_angle)
  self.x = start_x or love.math.random(constants.GAME_WIDTH)
  self.y = start_y or love.math.random(constants.GAME_HEIGHT)
  self.angle = start_angle or love.math.random() * (2*math.pi)
  self.speed = 50
  self.vx = self.speed * math.cos(self.angle)
  self.vy = self.speed * math.sin(self.angle)  
end,

update = function(self, dt)
  -- Change ball speed?
  --self.vx = 

  Entity.update(self, dt)
  
  -- Check ball bounds
  if self.x<=0 or self.x>constants.GAME_WIDTH then
   self.vx = self.vx * -1 
  elseif self.y<=0 or self.y>constants.GAME_HEIGHT then
   self.vy = self.vy * -1 
  end
  
  -- -- Rotate
  -- if not self:animationsInclude('rotation') then
  --   self.rotation = self.rotation + self.vr * dt
  -- end
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