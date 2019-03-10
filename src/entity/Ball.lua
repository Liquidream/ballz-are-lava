
local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'
local Sounds = require 'src/util/sounds'
local gfx = require 'src/util/gfx'

local SPRITESHEET = SpriteSheet.new('assets/img/ball.png', {
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

  if game_state==constants.GAME_STATE.LVL_PLAY then
   -- TODO: also include PAUSE power-up
   -- (tho maybe better to have a factor, so can slow/speedup!)
   Entity.update(self, dt)
  end
  
  local ballDidBounce = false
  -- Check ball bounds
  if self.x<=0 or self.x>constants.GAME_WIDTH then
   self.vx = self.vx * -1 
   -- move away from boundary
   self.x = self.x + self.vx * dt
   ballDidBounce = true
  elseif self.y<=0 or self.y>constants.GAME_HEIGHT then
   self.vy = self.vy * -1 
   -- move away from boundary
   self.y = self.y + self.vy * dt
   ballDidBounce = true
  end

  -- (Temp disabled until can tie in more visually?)
  -- if ballDidBounce then
  --   Sounds.bounce:playWithPitch(1.0 + math.random())
  -- end
  
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
 local x = self.x + gfx.shakeX
 local y = self.y + gfx.shakeY

 local sprite = (self.ball_type==constants.BALL_TYPES.LAVA) and "LAVABALL" or "TARGET"
 if sprite == "LAVABALL" then
  local offset = math.abs(math.sin(self.timeAlive * 8))
  love.graphics.setColor(0.5+math.max(0.25,offset), math.max(0.25,offset), math.max(0.25,offset))
 else
  love.graphics.setColor(1, 1, 1)
 end
 SPRITESHEET:drawCentered(sprite, x, y, nil, nil, nil, self.size, self.size)

end,
})

return Ball
