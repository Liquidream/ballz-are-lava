
local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'
local colour = require 'src/util/colour'
local gfx = require 'src/util/gfx'


local SPRITESHEET = SpriteSheet.new('assets/img/player.png', {
  BASE = { 0, 0, 32, 32 },
  EMPTY_HEART = { 0, 32, 16, 16 }
})


local Player = Entity.extend({
  lives = 3
  ,
  constructor = function(self)
    Entity.constructor(self)
    -- self.property = value
  
  end,
  
  resetState = function(self)
    self.size = 0.25      -- 0..1 (scale)
    self.radius = 8      -- For drawing/collisions (18 max)
    self.targetsCollected = 0
    self.shrinkPower = 0  --  "     "
    self.shrinked = false
    self.shrinkTimer = 0
    self.renderLayer=7
    self.deathCooldown=-1
  end,

update = function(self, dt)
  -- Size (based on # of targets collected)
  local smallestRadius = 8
  if not self.shrinked then
    self.radius = (self.targetsCollected*0.5)+smallestRadius
  else
    self.radius = smallestRadius -- (starting size)
  end

  -- Should player be able to move?
  if gameState~=constants.GAME_STATE.LVL_PLAY 
   and gameState~=constants.GAME_STATE.LVL_INTRO then
    -- bail out now
    return
  end

  -- Power-ups (duration)
  if self.powerup then
    self.powerupTimer = self.powerupTimer  - 0.016
    if self.powerupTimer <= 0 then
      -- Power-up over
      self.powerup = constants.POWERUP_TYPES.NONE
    end
    -- update animation frame
    self.powerupFrame = (self.powerupFrame+self.powerupFrameSpeed)%self.powerupFrameMax
  end

  -- keyboard controls override mouse
  local speed = 75
  if love.keyboard.isDown("right") then
    self.x = self.x + speed * dt
  end
  if love.keyboard.isDown("left") then
    self.x = self.x - speed * dt
  end
  if love.keyboard.isDown("up") then
    self.y = self.y - speed * dt
  --print("up arrow pressed at "..total_time_elapsed)
  end
  if love.keyboard.isDown("down") then
    self.y = self.y + speed * dt
  end

  -- set player to position of the mouse (in game coord)
  if (mouseX ~= lastMouseX) then 
    self.x = mouseX -- mouse xpos
  end
  if (mouseY ~= lastMouseY) then 
    self.y = mouseY -- mouse ypos
  end
  --self.x, self.y = mouseX, mouseY

  -- keep player within screen bounds
  self.x = math.max(0, math.min(constants.GAME_WIDTH,self.x))
  self.y = math.max(0, math.min(constants.GAME_HEIGHT,self.y))

  -- increase player shrink size from start
  self.shrinkPower = math.min(self.shrinkPower+0.01, 1)
  --self.size = math.min(self.size+0.01, 1)
  --self.radius = self.size*18
end,
draw = function(self)
  local x = self.x
  local y = self.y

  
  -- (Sprite method)
  -- love.graphics.setColor(1, 1, 1)
  -- local sprite = 'BASE'
  -- SPRITESHEET:drawCentered(sprite, x, y, nil, nil, nil, self.size, self.size)
  
  -- (Draw shape method)
  local drawScale=self.radius+1
  love.graphics.setColor(colour[15])
  love.graphics.circle("fill", self.x, self.y, drawScale)
  -- love.graphics.setColor(colour[14])
  -- love.graphics.circle("fill", self.x, self.y, drawScale-1)
  love.graphics.setColor(colour[13])
  love.graphics.circle("fill", self.x, self.y, drawScale-1)
  love.graphics.setColor(colour[12])
  love.graphics.circle("fill", self.x, self.y, drawScale-3)
  -- Shrink power
  local shrinkDrawScale=(self.radius-4)*self.shrinkPower
  love.graphics.setColor(colour[18])
  love.graphics.circle("fill", self.x, self.y, shrinkDrawScale)
  love.graphics.setColor(colour[19])
  love.graphics.circle("fill", self.x, self.y, shrinkDrawScale-1)

  -- Power-up layers
  if self.powerup == constants.POWERUP_TYPES.INVINCIBILITY then
    -- and love.math.random(3)==1 then
      local colIndex=constants.POWERUP_INVINC_COLS[math.floor(self.powerupFrame)]
    love.graphics.setColor(colour[colIndex])
    love.graphics.circle("line", self.x, self.y, drawScale+2)--+love.math.random(4))
  end

  -- Debug collisions, etc.
  if constants.DEBUG_MODE then
    love.graphics.setColor(colour[25])
    love.graphics.circle("line", self.x, self.y, self.radius)
  end
end,
onDeath = function(self) 
 self.lives = self.lives - 1
 self.deathCooldown = 100
 -- -- create "death" explosion particles
 -- gfx.boom(self.x, self.y, 500, constants.PLAYER_DEATH_COLS)
end,

})

Player:resetState()

return Player
