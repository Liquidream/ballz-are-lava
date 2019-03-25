
local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local SpriteSheet = require 'src/util/SpriteSheet'
local Sounds = require 'src/util/sounds'
local gfx = require 'src/util/gfx'
local colour = require 'src/util/colour'
local Sounds = require 'src/util/sounds'

local SPRITESHEET = SpriteSheet.new('assets/img/powerup.png', {
  P_1 = { 0,  0, 16, 16 }, -- SHIELD
  P_2 = { 64, 0, 16, 16 }, -- TIME_EXTEND
  P_3 = { 32, 0, 16, 16 }, -- LAVABOMB
  P_4 = { 16, 0, 16, 16 }, -- FREEZE
  P_5 = { 80, 0, 16, 16 }, -- INVINCIBILITY
  P_6 = { 48, 0, 16, 16 }, -- EXTRA_LIFE
  -- Flash versions
  P_1F = { 0,  16, 16, 16 }, -- SHIELD
  P_2F = { 64, 16, 16, 16 }, -- TIME_EXTEND
  P_3F = { 32, 16, 16, 16 }, -- LAVABOMB
  P_4F = { 16, 16, 16, 16 }, -- FREEZE
  P_5F = { 80, 16, 16, 16 }, -- INVINCIBILITY
  P_6F = { 48, 16, 16, 16 }, -- EXTRA_LIFE
})

local PowerUp = Entity.extend({
  size = 1, -- 0..1 (scale)
  radius = 8,
  
  constructor = function(self)
    Entity.constructor(self)
    
    
    print("max = "..self.maxPowerUpType)
    self.x = love.math.random(constants.GAME_WIDTH-20)+10
    self.y = love.math.random(constants.GAME_HEIGHT-20)+10
    self.powerupType = love.math.random( math.min(self.maxPowerUpType,6) )
    self.state = constants.POWERUP_STATE.HIDING -- HIDING
    self.frame = 1
    self.frame_delay = 0
    self.maxPowerUpType = 0
 end,
 
activate = function(self, player)
  print("powerupType:"..self.powerupType)
  -- Activate the Power-up, depending on the type
  if self.powerupType == constants.POWERUP_TYPES.SHIELD then
    player.powerup = self.powerupType
    player.powerupTimer = 6
    player.powerupFrame = 1
    player.powerupFrameSpeed = 0.25
    player.powerupFrameMax = 4
    Sounds.shield:play()
  
  elseif self.powerupType == constants.POWERUP_TYPES.FREEZE then
    player.powerup = self.powerupType
    player.powerupTimer = 5
    player.powerupFrame = 1
    Sounds.freeze:play()
    Sounds.freezeTimerLoop:play()
    -- quiet volume while freeze sound is playing
    Sounds.playingLoop:setVolume(constants.MUSIC_VOLUME / 2.0)

  elseif self.powerupType == constants.POWERUP_TYPES.EXTRA_LIFE then
    player.lives = player.lives + 1
    Sounds.extraLife:play()

  elseif self.powerupType == constants.POWERUP_TYPES.TIME_EXTEND then
    gameTimer = gameTimer + 10
    Sounds.timeExtend:play()

  elseif self.powerupType == constants.POWERUP_TYPES.INVINCIBILITY then
    player.powerup = self.powerupType
    player.powerupTimer = 6
    player.powerupFrame = 1
    player.powerupFrameSpeed = 0.25
    player.powerupFrameMax = 4
    Sounds.invincible:play()

  else
    -- shouldn't be possible
  end
 --{ NONE=0, SHIELD=1, FREEZE=2, LAVABOMB=3, EXTRA_LIFE=4, TIME_EXTEND=5, INVINCIBILITY=6 }

  -- Finally, remove/hide the Power-up (from being collected again)
  self.state = constants.POWERUP_STATE.DEAD
end,

update = function(self, dt)
    -- Check to see if time to "be alive" yet
    if gameTimer < self.startTime 
    and gameTimer > self.startTime-10
    and self.state == constants.POWERUP_STATE.HIDING then
      self.state = constants.POWERUP_STATE.VISIBLE
    end
  -- if gameState==constants.gameState.LVL_PLAY then
  --  -- TODO: also include PAUSE power-up
  --  -- (tho maybe better to have a factor, so can slow/speedup!)
  --  Entity.update(self, dt)
  -- end
end,

draw = function(self)
  local x = self.x 
  local y = self.y 

  -- Call "base" draw() function
  Entity.draw(self)

  -- Should we draw the Power-up?
  if self.state == constants.POWERUP_STATE.VISIBLE then
    local sprite = "P_"..self.powerupType
    if (gameTimer*10)%20 < .5 then
     sprite = sprite.."F"
    end
    love.graphics.setColor(1, 1, 1)
    SPRITESHEET:drawCentered(sprite, x, y, nil, nil, nil, 1, 1)

    -- Debug collisions, etc.
    if constants.DEBUG_MODE then
      love.graphics.setColor(colour[25])
      love.graphics.circle("line", self.x, self.y, self.radius)
    end
  end
end,

})

PowerUp.SPRITESHEET = SPRITESHEET

return PowerUp
