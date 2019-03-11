
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
  lives = 3,
  size = 0.25, -- 0..1 (scale)
  radius = 18,
  renderLayer=7,
  deathCooldown=-1,
  powerup = nil,
  powerupTimer = 3,
  powerupFrame = 1,

constructor = function(self)
  Entity.constructor(self)
  -- self.property = value
end,
update = function(self, dt)

 -- Should player be able to move?
 if game_state~=constants.GAME_STATE.LVL_PLAY 
 and game_state~=constants.GAME_STATE.LVL_INTRO then
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

  -- increase player size from start
  self.size = math.min(self.size+0.01, 1) --0.75)--1
end,
draw = function(self)
  local x = self.x
  local y = self.y

  -- (Draw shape method)
  --  love.graphics.setColor(colour[14])
  --  love.graphics.circle("fill", self.x, self.y, self.size*18)

  -- (Sprite method)
  love.graphics.setColor(1, 1, 1)
  local sprite = 'BASE'
  SPRITESHEET:drawCentered(sprite, x, y, nil, nil, nil, self.size, self.size)

  print("player pos="..x..","..y.." (size="..self.size..")")

  -- Power-up layers
  if self.powerup == constants.POWERUP_TYPES.INVINCIBILITY then
    -- and love.math.random(3)==1 then
    love.graphics.setColor(colour[8+love.math.random(3)])
    love.graphics.circle("line", self.x, self.y, self.size*20+love.math.random(4))
  end

end,
onDeath = function(self) 
 self.lives = self.lives - 1
 self.deathCooldown = 100
 -- -- create "death" explosion particles
 -- gfx.boom(self.x, self.y, 500, constants.PLAYER_DEATH_COLS)
end,

})

return Player
