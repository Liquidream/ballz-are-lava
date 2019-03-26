
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
    self.timeAlive = self.timeAlive + dt
    --self:applyVelocity(dt)
    --self:applyAnimations(dt)
  end,
  draw = function(self)
    love.graphics.setColor(1, 1, 1)
  end,
  setVelocity = function(self, vx, vy)
    self.vx = vx
    self.vy = vy
    self.vxPrev = vx
    self.vyPrev = vy
  end,
  applyVelocity = function(self, dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    self.vxPrev = self.vx
    self.vyPrev = self.vy
  end,
  countDownToDeath = function(self, dt)
    if self.timeToDeath > 0 then
      self.timeToDeath = self.timeToDeath - dt
      if self.timeToDeath <= 0 then
        self:die()
        return true
      end
    end
    return false
  end,
 die = function(self)
   if self.isAlive then
     self.isAlive = false
     self:onDeath()
   end
 end,
 onDeath = function(self) end,
 onMousePressed = function(self, x, y) end,

})

return Entity
