local constants = require 'src/constants'
local gfx = require 'src/util/gfx'
local Entity = require 'src/entity/Entity'
local listHelpers = require 'src/util/list'
local Promise = require 'src/util/Promise'
local Player = require 'src/entity/Player'
local Ball = require 'src/entity/Ball'
local colour = require 'src/util/colour'
local generateLevel = require 'src/generateLevel'
local collision = require 'src/util/collision'
local SpriteSheet = require 'src/util/SpriteSheet'
local Sounds = require 'src/util/sounds'

--
-- global vars
--
mouseX=nil  -- mouse pos (in game co-ordinates)
mouseY=nil
-- state variable(s)
game_state=constants.GAME_STATE.LVL_PLAY

--
-- local vars
--
local SPRITESHEET = SpriteSheet.new('assets/img/game-ui.png', {
 EMPTY_HEART = { 0, 0, 16, 16 },
 INTRO_3 = { 0, 16, 32, 48 },
 INTRO_2 = { 32, 16, 32, 48 },
 INTRO_1 = { 64, 16, 32, 48 },
 INTRO_0 = { 96, 16, 80, 48 },
 GAME_OVER = { 0, 64, 138, 112 },
})

-- Initialize game vars
local entities = {}
local lavaBalls = {}
local targetBalls = {}
local levelNum = 10
local gameTimer = 60
local delayCounter = 0
local txtSize = 0
local currLevel = nil


-- 
-- Entity code
-- 
Entity.spawn = function(class, args)
 local entity = class.new(args)
 table.insert(entities, entity)
 return entity
end

local function removeDeadEntities(list)
 return listHelpers.filter(list, function(entity)
   return entity.isAlive
 end)
end



-- -----------------------------------------------------------
-- Init code
-- -----------------------------------------------------------

-- Initialize all sounds
local function initSounds()
  Sounds.bounce = Sound:new('bounce.mp3', 16)
  Sounds.bounce:setVolume(0.1)

  Sounds.collect = Sound:new('collect.mp3', 4)
  Sounds.collect:setVolume(0.5)

  Sounds.loseLife = Sound:new('lose_life.mp3', 4)
  Sounds.loseLife:setVolume(0.5)

  Sounds.ballzMoving = Sound:new('ballz_moving.mp3', 1)
  Sounds.ballzMoving:setVolume(0.2)
  Sounds.ballzMoving:setLooping(true)

  Sounds.beatLevel = Sound:new('beat_level.mp3', 1)
  Sounds.beatLevel:setVolume(0.5)
end

-- Init level (either for first time or after restart)
local function initLevel(levelNum)

 -- Remove any existing balls
 for index, tball in ipairs(targetBalls) do
  tball:die()
 end
 for index, lball in ipairs(lavaBalls) do
  lball:die()
 end

 -- Generate a new level
 currLevel = generateLevel(levelNum)

 -- Create lava balls
 for i=1,currLevel.numLavaBalls do
  table.insert(lavaBalls, Ball:spawn({
   -- optional overloads
  }))
 end

 -- Create target balls
 for i=1,currLevel.numTargetBalls do
  table.insert(targetBalls, Ball:spawn({
   -- optional overloads
   ball_type=constants.BALL_TYPES.TARGET,
  }))
 end

  -- calc level time
  gameTimer = currLevel.numTargetBalls+10+0.9

 -- revive player player state (start small, etc.)
 if not p1.isAlive then
  table.insert(entities, p1)
  p1.isAlive = true
  p1.timeAlive = 0
  p1.size = 0.25
 end

 -- Start player with invincibility
 p1.powerup = constants.POWERUP_TYPES.INVINCIBILITY
 p1.powerupTimer = 5
 p1.powerupFrame = 1
 
 -- Intro (3 sec countdown)
 game_state=constants.GAME_STATE.LVL_INTRO
 delayCounter = 3

 --game_state=constants.GAME_STATE.LVL_PLAY

 Sounds.ballzMoving:play()
end

-- -----------------------------------------------------------
-- Update code
-- -----------------------------------------------------------

local function loseLife()
  print("dead!!")
  p1:die()
  -- create "death" explosion particles
  gfx.boom(p1.x, p1.y, 750, constants.PLAYER_DEATH_COLS)
  gfx:shake(1)
  -- lose life
  game_state = constants.GAME_STATE.LOSE_LIFE
  Sounds.loseLife:play()
  Sounds.ballzMoving:stop()
end


local function updatePlayerCollisions()
  -- lava balls 
  for index, lball in ipairs(lavaBalls) do
    if collision.objectsAreTouching(p1,lball) then
      -- Player death (unless invinc/shield)
      if p1.powerup == constants.POWERUP_TYPES.INVINCIBILITY then
        -- do nothing      
      elseif p1.powerup == constants.POWERUP_TYPES.SHIELD then
        print("TODO: LOSE SHIELD! >>>>")
        p1.powerup = constants.POWERUP_TYPES.NONE
      else
        loseLife()
      end
    end
  end
  -- target balls
  --print("#targetBalls="..#targetBalls)
  for index, tball in ipairs(targetBalls) do
    if collision.objectsAreTouching(p1,tball) then
      tball:die()
      collectedLastBall = (#targetBalls-1 == 0)

      if not collectedLastBall then
        levelProgress = ((currLevel.numTargetBalls - #targetBalls + 1) / currLevel.numTargetBalls)
        Sounds.collect:playWithPitch(1.0 + levelProgress)
      end

      if collectedLastBall then
        -- level complete
        print("level complete!!")
        Sounds.ballzMoving:stop()
        Sounds.beatLevel:play()
        game_state=constants.GAME_STATE.LVL_END

        -- (TODO: Show score, etc.)

        -- Next level (after delay)
        -- TODO: Probably not using Promise, 
        --       as will be after scores have tallied!
        Promise.newActive(2.5)
        :andThen(function()
          print(">>>level up!!!")
          levelNum = levelNum+1
          initLevel(levelNum)
        end)
      end 
    end
  end
end



-- -----------------------------------------------------------
-- Draw code
-- -----------------------------------------------------------

local function drawBackground()
 local gridSize=16
 -- navy
 -- love.graphics.clear(colour[26])
 -- love.graphics.setColor(colour[24])
 -- "black"
 love.graphics.clear(colour[26])
 love.graphics.setColor(colour[24])
 --
 for x=0, constants.GAME_WIDTH, gridSize do
    love.graphics.line(
      x,0,
      x,constants.GAME_HEIGHT)
 end
 for y=0, constants.GAME_HEIGHT, gridSize do
    love.graphics.line(
      0,y,
      constants.GAME_WIDTH,y)
 end

 -- remember values
 lastMouseX, lastMouseY = mouseX, mouseY
end

local function drawUI()
  love.graphics.setColor(1, 1, 1)
  -- lives
  for i=1,p1.lives do
    SPRITESHEET:drawCentered('EMPTY_HEART',
      i*18-8 , 9 , 
      nil, nil, nil, 1, 1)
  end

  -- state-dependent overlays
  if game_state == constants.GAME_STATE.LVL_INTRO then
    -- intro countdown
    SPRITESHEET:drawCentered('INTRO_'..delayCounter,
                              constants.GAME_WIDTH/2, constants.GAME_HEIGHT/2, 
                              nil, nil, nil, txtSize, txtSize)
  elseif game_state == constants.GAME_STATE.GAME_OVER then
    -- Game Over!
    SPRITESHEET:drawCentered('GAME_OVER',
                              constants.GAME_WIDTH/2, constants.GAME_HEIGHT/2, 
                              nil, nil, nil, txtSize, txtSize)
  end
  -- timer
  love.graphics.setColor(colour[19])
  love.graphics.printf('TIME:'..string.format("%02d", math.floor(gameTimer)),
    constants.GAME_WIDTH/2-80/2 ,
    1 ,
    80,"center")
    
  -- score
  love.graphics.setColor(colour[18])
  love.graphics.printf('000000',360 ,1 ,150,"right")
end


-- -----------------------------------------------------------
-- Main functions
-- -----------------------------------------------------------

local function load()

 -- Init sounds
 initSounds()

 -- -- Start at the title screen
 -- initTitleScreen(true)

 -- Create player
 p1 = Player:spawn({
   x = constants.GAME_WIDTH/2,
   y = constants.GAME_HEIGHT/2,
 })

 initLevel(levelNum)
end


local function update(dt)

  -- Update all promises
  Promise.updateActivePromises(dt)

  -- Update mouse position
  -- get the position of the mouse
  mouseX, mouseY = love.mouse.getPosition()
  -- adjust mouse position for scale
  mouseX = math.floor((mouseX-gfx.RENDER_X) / gfx.RENDER_SCALE)
  mouseY = math.floor((mouseY-gfx.RENDER_Y) / gfx.RENDER_SCALE)



  -- Update all entities
  local index, entity
  for index, entity in ipairs(entities) do
    if entity.isAlive then
      entity.timeAlive = entity.timeAlive + dt
      entity:update(dt)
      entity:countDownToDeath(dt)
    end
  end

  -- Level Intro
  if game_state == constants.GAME_STATE.LVL_INTRO then
    txtSize = txtSize + .07
    if txtSize > 3 then 
      txtSize = 0
      delayCounter = delayCounter - 1
      if delayCounter < 0 then
        game_state = constants.GAME_STATE.LVL_PLAY
      end
    end

  -- Game play
  elseif game_state == constants.GAME_STATE.LVL_PLAY 
   or game_state == constants.GAME_STATE.LOSE_LIFE then

    -- Update player (if alive)
    if p1.isAlive then
      p1:update(dt)
      -- check player collisions
      updatePlayerCollisions()
    else
      -- Player died
      p1.deathCooldown = p1.deathCooldown-1
      if p1.deathCooldown <= 0 then
        -- Restart level?
        if p1.lives > 0 then
          initLevel(levelNum)
        else
          -- game over
          game_state = constants.GAME_STATE.GAME_OVER
          print("game over!!!")
          txtSize = 0
        end
      end
    end

  -- Game over
  elseif game_state == constants.GAME_STATE.GAME_OVER then
    -- text
    txtSize = txtSize + .03
    txtSize = math.min(txtSize, 1.75)
    -- fireworks!
    if love.math.random(15)==1 and #lavaBalls > 0 then 
      -- kill lavaball
      gfx.boom(lavaBalls[1].x, lavaBalls[1].y, 200, constants.LAVA_DEATH_COLS)
      --boom(lavaBalls[1].x, lavaBalls[1].y, 25, lava_death_cols)
      lavaBalls[1]:die()
      --del(lava_balls, lava_balls[1])
    end
    if love.math.random(15)==1 and #targetBalls > 0 then 
      -- kill target
      gfx.boom(targetBalls[1].x, targetBalls[1].y, 150, constants.PLAYER_DEATH_COLS)
      targetBalls[1]:die()
      --del(targets, targets[1])
    end
  end -- if gamestate

  -- Decrease game timer
  if game_state == constants.GAME_STATE.LVL_PLAY then
    gameTimer = gameTimer - 0.016
    if gameTimer < 1 then
      gameTimer = 0 
      loseLife()
    end
  end

  -- update particles
  gfx.updateParticles(dt)

  -- Remove dead entities
  targetBalls = removeDeadEntities(targetBalls)
  lavaBalls = removeDeadEntities(lavaBalls)
  entities = removeDeadEntities(entities)
  -- Sort entities for rendering
  table.sort(entities, function(a, b)
    return a.renderLayer < b.renderLayer
  end)
end



local function draw()

  -- Adjust/update shack positioning first (if any)
  gfx:updateShake()


  -- Draw background
  drawBackground()

  -- Draw all entities (inc. player)
  for index, entity in ipairs(entities) do
    love.graphics.setColor(1, 1, 1)
    entity:draw()
  end

  -- draw particles
  gfx:drawParticles()

  -- DEBUG: Draw game boundary
  -- love.graphics.setColor(colour[27])
  -- love.graphics.rectangle("line", 0, 0, constants.GAME_WIDTH, constants.GAME_HEIGHT )

  -- draw ui
  drawUI()

  -- draw other effects
  if p1.deathCooldown > 96 then
    love.graphics.clear(colour[25])
  end

end



return {
 load = load,
 update = update,
 draw = draw,
}