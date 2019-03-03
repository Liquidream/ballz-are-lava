local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'

local SPRITESHEET = SpriteSheet.new('img/ball.png', {
  LAVABALL = { 0, 0, 16, 16 },
  TARGET = { 16, 0, 16, 16 },
})

local Ball = Entity.extend({
 size = 1, -- 0..1 (scale)
 radius = 1,
 ball_type = constants.BALL_TYPES.LAVA,
 speed = 100,
 
 constructor = function(self)
  Entity.constructor(self)
  
  self.x = love.math.random(constants.GAME_WIDTH-20)+10
  self.y = love.math.random(constants.GAME_HEIGHT-20)+10
  self.angle = love.math.random() * (2*math.pi)
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

 local sprite = (self.ball_type==constants.BALL_TYPES.LAVA) and "LAVABALL" or "TARGET"
 if sprite == "LAVABALL" then
  local offset = math.abs(math.sin(self.timeAlive * 8))
  love.graphics.setColor(0.5+math.max(0.25,offset), math.max(0.25,offset), math.max(0.25,offset))
 else
  love.graphics.setColor(1, 1, 1)
 end
 SPRITESHEET:drawCentered(sprite, self.x, self.y, nil, nil, nil, self.size, self.size)

end,
})

return Ball