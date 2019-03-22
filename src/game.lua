local constants = require 'src/constants'
local gfx = require 'src/util/gfx'
local Entity = require 'src/entity/Entity'
local listHelpers = require 'src/util/list'
local Promise = require 'src/util/Promise'
local Player = require 'src/entity/Player'
local Ball = require 'src/entity/Ball'
local PowerUp = require 'src/entity/PowerUp'
local colour = require 'src/util/colour'
local generateLevel = require 'src/generateLevel'
local collision = require 'src/util/collision'
local SpriteSheet = require 'src/util/SpriteSheet'
local Sounds = require 'src/util/sounds'
local Scenes = require 'src/scenes'

require 'src/util/controller'
--local controller = require 'src/util/controller'


--
-- global vars
--
firstLoad = true
mouseX = nil  -- mouse pos (in game co-ordinates)
mouseY = nil
lastMouseBtnDownState = false
actionButtonPressed = false
-- state variable(s)
-- gameState = constants.GAME_STATE.TITLE
--gameState = constants.GAME_STATE.LVL_PLAY

gameTimer = 60  -- (Made Global so Power-ups can read it)
gamePowerUp = 0       -- for Freeze powerup
gamePowerUpTimer = 0  -- 
gamePowerUpFrame = 0
gameDeathLinesCount = 0 -- Not for first few levels
gameDeathLines = {}   -- Death lines for Death Balls!
levelNum = 3--3--12
livesAtLevelStart = 0
--
-- local vars
--
local SPRITESHEET = SpriteSheet.new('assets/img/game-ui.png', {
  EMPTY_HEART = { 0, 0, 16, 16 },
  INTRO_3 = { 0, 16, 24, 40 },
  INTRO_2 = { 32, 16, 24, 40 },
  INTRO_1 = { 64, 16, 24, 40 },
  INTRO_0 = { 96, 16, 56, 40 },
  GAME_OVER = { 0, 64, 120, 104 },
})

-- Initialize game vars
local lavaBalls = {}
local powerUps = {}
local targetBalls = {}
local delayCounter = 0
local txtSize = 0
local currLevel = nil



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

  Sounds.collectPowerUp = Sound:new('collect.mp3', 4)
  Sounds.collectPowerUp:setVolume(0.5)
end

-- Init level (either for first time or after restart)
local function initLevel(levelNum)

  -- Remove any existing content
  targetBalls={}
  lavaBalls={}
  powerUps={}

  -- Generate a new level properies (num balls, etc.)
  currLevel = generateLevel(levelNum)

  -- Create lava balls
  for i=1,currLevel.numLavaBalls do
    table.insert(lavaBalls, Ball.new({
      -- optional overloads
      id=i
    }))
  end

  -- Create target balls
  for i=1,currLevel.numTargetBalls do
    table.insert(targetBalls, Ball.new({
      -- optional overloads
      ball_type=constants.BALL_TYPES.TARGET,
    }))
  end

  -- Create Power-Ups
  for i=1,currLevel.numPowerUps do
    table.insert(powerUps, PowerUp.new({
      -- optional overloads
      startTime = love.math.random(currLevel.numTargetBalls+5+0.9)+5,
      maxPowerUpType = levelNum-2
    }))
  end

  -- Enable death lines?
  gameDeathLinesCount = math.min(math.floor(levelNum/3), 3)

  -- debug!!!!
  -- print("# Powerups:"..#powerUps)
  -- for index, pUp in ipairs(powerUps) do
  --   print(">> Type: "..pUp.powerupType.." @ "..pUp.x..","..pUp.y)
  -- end

  -- calc level time
  gameTimer = currLevel.numTargetBalls+10+0.9

  -- revive player player state (start small, etc.)
  p1:resetState()

  -- Start player with invincibility
  p1.powerup = constants.POWERUP_TYPES.INVINCIBILITY
  p1.powerupTimer = 3
  p1.powerupFrame = 1
  p1.powerupFrameSpeed = 0.25
  p1.powerupFrameMax = 4

  -- Game PowerUps
  gamePowerUp = 0
  gamePowerUpTimer = 0

  -- Intro (3 sec countdown)
  gameState=constants.GAME_STATE.LVL_INTRO
  delayCounter = 3

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
  gameState = constants.GAME_STATE.LOSE_LIFE
  Sounds.loseLife:play()
  Sounds.ballzMoving:stop()
end

local function playerDieUnlessProtected()
  -- Player death (unless invinc/shield)
  if p1.powerup == constants.POWERUP_TYPES.INVINCIBILITY then
    -- do nothing      
  elseif p1.powerup == constants.POWERUP_TYPES.SHIELD then
    -- Lose shield!
    gfx:shake(0.5)
    Sounds.loseLife:play()
    -- Temp invincibility
    p1.powerup = constants.POWERUP_TYPES.INVINCIBILITY
    p1.powerupTimer = 1 
    --p1.powerup = constants.POWERUP_TYPES.NONE
  else
    loseLife()
  end
end


local function updatePlayerCollisions()
  -- Death lines (if present)
  for index, src in ipairs(gameDeathLines) do
    for index, trg in ipairs(gameDeathLines) do
      if src.state>0 and collision.segmentVsCircle(src.x, src.y, trg.x, trg.y, p1.x, p1.y, p1.radius) then
        -- Player death (unless invinc/shield)
        playerDieUnlessProtected()
      end
    end
  end
  
  -- Lava balls 
  for index, lball in ipairs(lavaBalls) do
    if collision.objectsAreTouching(p1,lball) then
      -- Player death (unless invinc/shield)
      playerDieUnlessProtected()
    end
  end
  -- Target balls
  for index, tball in ipairs(targetBalls) do
    if collision.objectsAreTouching(p1,tball) then
      tball:die()
      table.remove(targetBalls, index)
      p1.targetsCollected = p1.targetsCollected + 1
      collectedLastBall = (#targetBalls == 0)

      if not collectedLastBall then
        levelProgress = ((currLevel.numTargetBalls - #targetBalls + 1) / currLevel.numTargetBalls)
        Sounds.collect:playWithPitch(1.0 + levelProgress)
      end

      if collectedLastBall then
        -- level complete
        print("level complete!!")
        Sounds.ballzMoving:stop()
        Sounds.beatLevel:play()
        gameState=constants.GAME_STATE.LVL_END

        -- (TODO: Show score, etc.)
        Scenes:initLevelEnd(p1)

        -- Next level (after delay)
        -- TODO: Probably not using Promise, 
        --       as will be after scores have tallied!
        -- Promise.newActive(2.5)
        -- :andThen(function()
        --   print(">>>level up!!!")
        --   levelNum = levelNum+1
        --   initLevel(levelNum)
        -- end)
      end 
    end
  end
  -- Power-Ups
  for index, pUp in ipairs(powerUps) do
    if collision.objectsAreTouching(p1,pUp)
     and pUp.state == constants.POWERUP_STATE.VISIBLE then
      -- Collected power-up
      table.remove(powerUps,index)
      -- TODO: different SFX?
      Sounds.collectPowerUp:play()
      pUp:activate(p1)

      -- Special power-ups
      -- BOOM!
      if pUp.powerupType == constants.POWERUP_TYPES.LAVABOMB then
        local n=love.math.random(#lavaBalls/4)+1
        for k = 1,n do
          local boomBall = table.remove(lavaBalls)
          -- kill lavaball
          gfx.boom(boomBall.x, boomBall.y, 200, constants.LAVA_DEATH_COLS)
          boomBall:die()
        end
      end
      -- FREEZE
      if pUp.powerupType == constants.POWERUP_TYPES.FREEZE then
        gamePowerUp = pUp.powerupType
        gamePowerUpTimer = 3
        gamePowerUpFrame = 1
      end

      -- skip other power-ups this cycle
      -- (shouldn't be any more - save cpu)
      return
    end
  end
end



-- -----------------------------------------------------------
-- Draw code
-- -----------------------------------------------------------

local function drawBackground()
 local gridSize=16
 local lineCols={[0]=24, 6, 15}
 -- navy
 love.graphics.clear(colour[26])
 love.graphics.setColor(colour[lineCols[levelNum%3]])
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
      i*18-10 , 8 , 
      nil, nil, nil, 1, 1)
  end

  -- state-dependent overlays
  if gameState == constants.GAME_STATE.LVL_INTRO then
    -- intro countdown
    love.graphics.setColor(1, 1, 1, 6-txtSize)
    SPRITESHEET:drawCentered('INTRO_'..delayCounter,
                              constants.GAME_WIDTH/2, constants.GAME_HEIGHT/2, 
                              nil, nil, nil, txtSize, txtSize)
  elseif gameState == constants.GAME_STATE.GAME_OVER then
    -- Game Over!
    SPRITESHEET:drawCentered('GAME_OVER',
                              constants.GAME_WIDTH/2, constants.GAME_HEIGHT/2, 
                              nil, nil, nil, txtSize, txtSize)
  end
  -- Restore default colour
  love.graphics.setColor(1, 1, 1)
  
  -- timer
  gfx.drawOutlineText('TIME:'..string.format("%02d", math.floor(gameTimer)),
    constants.GAME_WIDTH/2-80/2 ,
    1 ,
    80,"center",
    (gameTimer<10 and gameState == constants.GAME_STATE.LVL_PLAY) and colour[25] or colour[19])
    
  -- score
  gfx.drawOutlineText(string.format("%08d", p1.score),360 ,1 ,150,"right",colour[18])

  if (constants.DEBUG_MODE) then drawControllersDebug() end
end


local function updatePlayerDeath(dt)

  --
  -- Update player death?
  --
  -- Player died
  p1.deathCooldown = p1.deathCooldown-1
  if p1.deathCooldown <= 0 then
    -- Restart level?
    if p1.lives > 0 then
      initLevel(levelNum)
    else
      -- game over
      gameState = constants.GAME_STATE.GAME_OVER
      Scenes:initGameOver()
      print("game over!!!")
      txtSize = 0
    end
  end
end

local function updateBalls(dt)

  -- Update Target Balls
  for index, tball in ipairs(targetBalls) do
    tball:update(dt)
    if gameState == constants.GAME_STATE.LVL_PLAY 
      and gamePowerUp ~= constants.POWERUP_TYPES.FREEZE then
      tball:applyVelocity(dt)
    end
  end
  -- Update Lava Balls
  for index, lball in ipairs(lavaBalls) do
    lball:update(dt)
    if gameState==constants.GAME_STATE.LVL_PLAY 
      and gamePowerUp ~= constants.POWERUP_TYPES.FREEZE then
      lball:applyVelocity(dt)
    end
  end

end

local function updatePowerUps(dt)

  -- Update Power-ups
  for index, pUp in ipairs(powerUps) do
    pUp:update(dt)
  end
  -- Game PowerUps
  if gamePowerUp then
    gamePowerUpTimer = gamePowerUpTimer - 0.016
    if gamePowerUpTimer <= 0 then
      -- PowerUp over
      gamePowerUp = 0
    end
    gamePowerUpFrame = (gamePowerUpFrame+1)%4
  end

end



-- -----------------------------------------------------------
-- Main functions
-- -----------------------------------------------------------

local function load()

  if firstLoad then
    -- Init sounds
    initSounds()

    -- Joystick/pad related
    print("joystick count="..love.joystick.getJoystickCount())
    checkControllers()
    
    firstLoad = false
  end

  -- -- Start at the title screen
  gameState = constants.GAME_STATE.TITLE

  -- Create player
  p1 = Player.new({
    x = constants.GAME_WIDTH/2,
    y = constants.GAME_HEIGHT/2,
  })

  Scenes:initTitle()
  --initLevel(levelNum)

end

function love.keypressed( key, scancode, isrepeat )
  -- Debug switch
  if key=="d" then
    constants.DEBUG_MODE = not constants.DEBUG_MODE
  end
  if key=="space" then
    actionButtonPressed = true
  end
end


local function update(dt)

  -- Update all promises
  Promise.updateActivePromises(dt)

  -- Update game controller(s)
  updateControllers(dt)
  if (constants.DEBUG_MODE) then updateControllersDebug(dt) end



  -- Update mouse position
  -- get the position of the mouse
  mouseX, mouseY = love.mouse.getPosition()
  -- adjust mouse position for scale
  mouseX = math.floor((mouseX-gfx.RENDER_X) / gfx.RENDER_SCALE)
  mouseY = math.floor((mouseY-gfx.RENDER_Y) / gfx.RENDER_SCALE)

  -- Action button (Controller)
  if #gamepads > 0 and controllerPressed(gamepads[1], "primaryA") then
    -- Sticky press (don't clear current value)
    actionButtonPressed = true
  end

  -- Action button (Mouse)
  local mouseBtnDownState = love.mouse.isDown(1)
  if mouseBtnDownState 
  and not lastMouseBtnDownState
  and not actionButtonPressed then
    -- Sticky press (don't clear current value)
    actionButtonPressed = true
  end

  -- Level Intro
  if gameState == constants.GAME_STATE.TITLE then
    Scenes:updateTitle(dt)
    if actionButtonPressed then 
      Scenes:initInstructions()
      gameState = constants.GAME_STATE.INFO
    end

  -- Instructions
  elseif gameState == constants.GAME_STATE.INFO then
    Scenes:updateInstructions(dt)
    -- Start game (level intro)
    if actionButtonPressed then 
      initLevel(levelNum)
      gameState = constants.GAME_STATE.LVL_INTRO
    end

  -- Level Intro
  elseif gameState == constants.GAME_STATE.LVL_INTRO then

    -- Allow player to move
    p1:update(dt)
    -- Update Lava + Target ballz (anim only)
    updateBalls(dt)

    txtSize = txtSize + .14
    if txtSize > 6 then 
      txtSize = 0
      delayCounter = delayCounter - 1
      if delayCounter < 0 then
        gameState = constants.GAME_STATE.LVL_PLAY
      end
    end

  -- Game play
  elseif gameState == constants.GAME_STATE.LVL_PLAY then

    -- Game update routine
    p1:update(dt)
    
    -- check player collisions
    updatePlayerCollisions()
    
    -- Update Lava + Target ballz
    updateBalls(dt)

    -- Update Power-ups (Player + game-level)
    updatePowerUps(dt)
    
    -- Decrease game timer
    gameTimer = gameTimer - 0.016
    if gameTimer < 1 then
      gameTimer = 0 
      loseLife()
    end

  -- Level Complete
  elseif gameState == constants.GAME_STATE.LVL_END then

    -- Update Lava + Target ballz (anim only)
    updateBalls(dt)

    -- Tally scores
    Scenes:updateLevelEnd(dt, p1)
    
    -- Allow skip score tally
    if actionButtonPressed then 
      -- Next level
      -- levelNum = levelNum+1
      -- initLevel(levelNum)
      -- gameState = constants.GAME_STATE.LVL_INTRO
    end

  -- Lose Life
  elseif gameState == constants.GAME_STATE.LOSE_LIFE then

    -- Countdown until restart/game-over
    updatePlayerDeath(dt)
    -- Update Lava + Target ballz (anim only)
    updateBalls(dt)

  -- Game over
  elseif gameState == constants.GAME_STATE.GAME_OVER then
    -- text
    txtSize = txtSize + .02
    txtSize = math.min(txtSize, 2)
    
    -- Update Lava + Target ballz (anim only)
    updateBalls(dt)

    -- fireworks!
    if love.math.random(15)==1 and #lavaBalls > 0 then 
      -- kill lavaball
      gfx.boom(lavaBalls[1].x, lavaBalls[1].y, 200, constants.LAVA_DEATH_COLS)
      lavaBalls[1]:die()
      table.remove(lavaBalls, 1)
    end
    if love.math.random(15)==1 and #targetBalls > 0 then 
      -- kill target
      gfx.boom(targetBalls[1].x, targetBalls[1].y, 150, constants.PLAYER_DEATH_COLS)
      targetBalls[1]:die()
      table.remove(targetBalls, 1)
    end

    Scenes:updateGameOver(dt)

    if actionButtonPressed then 
      -- TODO: Have a countdown that if player lets reach 0, go to Title

      -- Restart level
      p1.lives = livesAtLevelStart
      game.initLevel(levelNum)
    end

  end -- if gamestate


  -- update particles
  gfx.updateParticles(dt)

  -- Reset state for current frame
  actionButtonPressed = false
  lastMouseBtnDownState = mouseBtnDownState
end


local function drawGame()

  -- Draw "death" lines
  for index, src in ipairs(gameDeathLines) do
    for index, trg in ipairs(gameDeathLines) do
      love.graphics.setColor((src.state<2) and colour[25] or colour[11])
      love.graphics.line(src.x,src.y,trg.x,trg.y)
    end
  end
  
  -- Draw Target Balls
  for index, tball in ipairs(targetBalls) do
    tball:draw()
  end
  -- Draw Lava Balls
  for index, lball in ipairs(lavaBalls) do
    if gamePowerUp ~= 2 
     or (gamePowerUpTimer > 0.5 or gamePowerUpFrame == 0) then
      lball:draw()
    end
  end
  -- Draw Power-ups
  for index, pUp in ipairs(powerUps) do
    pUp:draw()
  end
  -- Draw Player
  if p1.isAlive then
    p1:draw()
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


local function draw()

  -- Adjust/update shack positioning first (if any)
  gfx:updateShake()


  -- Draw background
  drawBackground()

  -- Level Intro
  if gameState == constants.GAME_STATE.TITLE then

    Scenes.drawTitle()

    -- Instructions
  elseif gameState == constants.GAME_STATE.INFO then

    Scenes.drawInstructions()

  -- Level Intro
  elseif gameState == constants.GAME_STATE.LVL_INTRO then

    -- Draw game elements (inc. UI)
    drawGame()

    -- Game play
  elseif gameState == constants.GAME_STATE.LVL_PLAY then

    -- Draw game elements (inc. UI)
    drawGame()

  elseif gameState == constants.GAME_STATE.LVL_END then

    -- Draw game elements (inc. UI)
    drawGame()
    Scenes:drawLevelEnd(p1)

  -- Lose Life
  elseif gameState == constants.GAME_STATE.LOSE_LIFE then

    -- Draw game elements (inc. UI)
    drawGame()

  -- Game over
  elseif gameState == constants.GAME_STATE.GAME_OVER then
  
    -- Draw game elements (inc. UI)
    drawGame()
    Scenes:drawGameOver(p1)

  end


end



return {
 load = load,
 update = update,
 draw = draw,
 initLevel = initLevel,
}