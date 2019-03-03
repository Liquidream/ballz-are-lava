
local createClass = require 'src/util/createClass'

-- This is the base class for all game entities
-- (orig by bridgs - https://github.com/bridgs/quickdraw-blackjack)
local Entity = createClass({
 isAlive = true,
 x = 0,
 y = 0,
 vx = 0,
 vy = 0,
 vxPrev = nil,
 vyPrev = nil,
 frameRateIndependent = false,
 timeToDeath = 0,
 timeAlive = 0,
 renderLayer = 5,
 constructor = function(self)
   self.animations = {}
   self.renderLayer = self.renderLayer + math.random()
 end,
 update = function(self, dt)
   self:applyVelocity(dt)
   --self:applyAnimations(dt)
 end,
 draw = function(self) end,
 setVelocity = function(self, vx, y)
   self.vx = vx
   self.vy = vy
   self.vxPrev = vx
   self.vyPrev = vy
 end,
 applyVelocity = function(self, dt)
  -- if not self:animationsInclude('x') and not self:animationsInclude('y') then
  --   if self.frameRateIndependent and self.vxPrev ~= nil and self.vyPrev ~= nil then
  --     self.x = self.x + (self.vx + self.vxPrev) / 2 * dt
  --     self.y = self.y + (self.vy + self.vyPrev) / 2 * dt
  --   else
      self.x = self.x + self.vx * dt
      self.y = self.y + self.vy * dt
  --   end
  --end
  self.vxPrev = self.vx
  self.vyPrev = self.vy
 end,
 die = function(self)
  if self.isAlive then
    self.isAlive = false
    self:onDeath()
  end
 end,
 onDeath = function(self) end
})

return Entity