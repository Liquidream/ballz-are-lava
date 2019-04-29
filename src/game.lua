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
local saveFile = require 'src/util/saveFile'
local Sounds = require 'src/util/sounds'
local Scenes = require 'src/scenes'
local moonshine = require 'src/moonshine'
require 'src/util/controller'

-- Clear save file
saveFile.save(constants.SAVE_FILENAME, {})

--
-- global vars
--
firstLoad = true
mouseX = nil  -- mouse pos (in game co-ordinates)
mouseY = nil
lastMouseBtnDownState = false
actionButtonPressed = false
gameTimer = 60  -- (Made Global so Power-ups can read it)
gamePowerUp = 0       -- for Freeze powerup
gamePowerUpTimer = 0  -- 
gamePowerUpFrame = 0
gameDeathLinesCount = 0 -- Not for first few levels
gameDeathLines = {}   -- Death lines for Death Balls!
levelNum = 3
currCountdownMusic = nil
currPlayingMusic = nil
livesAtLevelStart = 3
highScore = 0
highLevel = 0
gameTimerAtPrevFrame = 10000
lavaBalls = {}

totalTime = 0
local MUSIC_BPM = 135
local SECONDS_PER_BEAT = (60 / MUSIC_BPM)
local timeSinceLastPulse = 2 * SECONDS_PER_BEAT


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

  Sounds.splashIntro = Sound:new('splash_intro.mp3', 1)
  Sounds.splashIntro:setVolume(0.7)

  Sounds.collect = Sound:new('collect.mp3', 4)
  Sounds.collect:setVolume(0.5)

  Sounds.loseLife = Sound:new('lose_life.mp3', 4)
  Sounds.loseLife:setVolume(0.8)

  Sounds.beatLevel = Sound:new('beat_level.mp3', 1)
  Sounds.beatLevel:setVolume(0.5)

  Sounds.extraLife = Sound:new('extra_life.mp3', 4)
  Sounds.extraLife:setVolume(0.5)

  Sounds.gameOver = Sound:new('game_over.mp3', 1)
  Sounds.gameOver:setVolume(0.75)

  Sounds.countdownTick = Sound:new('countdown_tick.mp3', 3)
  Sounds.countdownTick:setVolume(0.5)

  Sounds.countdownGo = Sound:new('countdown_go.mp3', 1)
  Sounds.countdownGo:setVolume(0.5)

  Sounds.lavabombExplode = Sound:new('lavabomb_explode.mp3', 10)
  Sounds.lavabombExplode:setVolume(1.0)

  Sounds.lvl1Intro = Sound:new('lvl_1_intro.mp3', 1)
  Sounds.lvl2And3Intro = Sound:new('lvl_2_and_3_intro.mp3', 1)
  Sounds.lvl4And5Intro = Sound:new('lvl_4_and_5_intro.mp3', 1)
  Sounds.lvl6PlusIntro = Sound:new('lvl_6_plus_intro.mp3', 1)
  Sounds.lvl1Intro:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl2And3Intro:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl4And5Intro:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl6PlusIntro:setVolume(constants.MUSIC_VOLUME)

  Sounds.lvl1 = Sound:new('lvl_1.mp3', 1)
  Sounds.lvl2 = Sound:new('lvl_2.mp3', 1)
  Sounds.lvl3 = Sound:new('lvl_3.mp3', 1)
  Sounds.lvl4 = Sound:new('lvl_4.mp3', 1)
  Sounds.lvl5 = Sound:new('lvl_5.mp3', 1)
  Sounds.lvl6AndEvens = Sound:new('lvl_6_and_evens.mp3', 1)
  Sounds.lvl7AndOdds = Sound:new('lvl_7_and_odds.mp3', 1)

  Sounds.lvl1:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl2:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl3:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl4:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl5:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl6AndEvens:setVolume(constants.MUSIC_VOLUME)
  Sounds.lvl7AndOdds:setVolume(constants.MUSIC_VOLUME)

  Sounds.lvl1:setLooping(true)
  Sounds.lvl2:setLooping(true)
  Sounds.lvl3:setLooping(true)
  Sounds.lvl4:setLooping(true)
  Sounds.lvl5:setLooping(true)
  Sounds.lvl6AndEvens:setLooping(true)
  Sounds.lvl7AndOdds:setLooping(true)

  Sounds.freezeTimerLoop = Sound:new('freeze_timer_loop.mp3', 1)
  Sounds.freezeTimerLoop:setVolume(0.4)
  Sounds.freezeTimerLoop:setLooping(true)

  Sounds.freeze = Sound:new('freeze.mp3', 2)
  Sounds.freeze:setVolume(1.0)

  Sounds.shield = Sound:new('shield.mp3', 2)
  Sounds.shield:setVolume(0.8)

  Sounds.invincible = Sound:new('invincible.mp3', 2)
  Sounds.invincible:setVolume(0.7)

  Sounds.timeExtend = Sound:new('time_extend.mp3', 2)
  Sounds.timeExtend:setVolume(0.6)

  Sounds.scoreCountTick = Sound:new('score_count_tick.mp3', 16)
  Sounds.scoreCountTick:setVolume(0.15)

  Sounds.loseShield = Sound:new('lose_shield.mp3', 1)
  Sounds.loseShield:setVolume(0.8)

  Sounds.menuBlip = Sound:new('menu_blip.mp3', 1)
  Sounds.menuBlip:setVolume(0.5)

  Sounds.five = Sound:new('5.mp3', 1)
  Sounds.four = Sound:new('4.mp3', 1)
  Sounds.three = Sound:new('3.mp3', 1)
  Sounds.two = Sound:new('2.mp3', 1)
  Sounds.one = Sound:new('1.mp3', 1)
  Sounds.five:setVolume(0.75)
  Sounds.four:setVolume(0.75)
  Sounds.three:setVolume(0.75)
  Sounds.two:setVolume(0.75)
  Sounds.one:setVolume(0.75)

  Sounds.kickAndCrash = Sound:new('kick_and_crash.mp3', 1)
  Sounds.kickAndCrash:setVolume(0.5)

  Sounds.kick = Sound:new('kick.mp3', 1)
  Sounds.kick:setVolume(0.5)

  Sounds.titleLoop = Sound:new('title_loop.mp3', 1)
  Sounds.titleLoop:setVolume(0.5)
  Sounds.titleLoop:setLooping(true)

  Sounds.instructionsLoop = Sound:new('instructions_loop.mp3', 1)
  Sounds.instructionsLoop:setVolume(0.5)
  Sounds.instructionsLoop:setLooping(true)
end

-- Init level (either for first time or after restart)
local function initLevel(levelNum)

  -- Remove any existing content
  targetBalls={}
  lavaBalls={}
  powerUps={}

  print("levelnum: "..levelNum)

  levelNumIndex = levelNum - 2

  if levelNumIndex == 1 then
    currPlayingMusic = Sounds.lvl1
    currCountdownMusic = Sounds.lvl1Intro
  elseif levelNumIndex == 2 then
    currPlayingMusic = Sounds.lvl2
    currCountdownMusic = Sounds.lvl2And3Intro
  elseif levelNumIndex == 3 then
    currPlayingMusic = Sounds.lvl3
    currCountdownMusic = Sounds.lvl2And3Intro
  elseif levelNumIndex == 4 then
    currPlayingMusic = Sounds.lvl4
    currCountdownMusic = Sounds.lvl4And5Intro
  elseif levelNumIndex == 5 then
    currPlayingMusic = Sounds.lvl5
    currCountdownMusic = Sounds.lvl4And5Intro
  elseif levelNumIndex >= 6 and levelNum % 2 == 0 then
    currPlayingMusic = Sounds.lvl6AndEvens
    currCountdownMusic = Sounds.lvl6PlusIntro
  elseif levelNumIndex >= 7 and levelNum % 2 == 1 then
    currPlayingMusic = Sounds.lvl7AndOdds
    currCountdownMusic = Sounds.lvl6PlusIntro
  end

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
  gameTimerAtPrevFrame = gameTimer

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
  txtSize = 0
  gameState=constants.GAME_STATE.LVL_INTRO
  Sounds.countdownTick:play()
  currCountdownMusic:play()
  Sounds.instructionsLoop:stop()
  delayCounter = 3
end

-- -----------------------------------------------------------
-- Update code
-- -----------------------------------------------------------

local function resetPulsingLineTimes()
  timeSinceLastPulse = 2 * SECONDS_PER_BEAT
end

local function updatePulsingLinesTimes(dt)
  timeSinceLastPulse = timeSinceLastPulse + dt
end

local function loseLife()
  print("dead!!")
  p1:die()
  -- create "death" explosion particles
  gfx.boom(p1.x, p1.y, 750, constants.PLAYER_DEATH_COLS)
  gfx:shake(1)
  -- lose life
  gameState = constants.GAME_STATE.LOSE_LIFE
  Sounds.freezeTimerLoop:stop()
  Sounds.loseLife:play()
  Sounds.kick:play()
  currPlayingMusic:stop()
end

local function playerDieUnlessProtected()
  -- Player death (unless invinc/shield)
  if p1.powerup == constants.POWERUP_TYPES.INVINCIBILITY then
    -- do nothing      
  elseif p1.powerup == constants.POWERUP_TYPES.SHIELD then
    -- Lose shield!
    gfx:shake(0.5)
    Sounds.loseShield:play()
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

        for k = 1,#lavaBalls do
          local boomBall = table.remove(lavaBalls)
          -- kill lavaball
          gfx.boom(boomBall.x, boomBall.y, 200, constants.LAVA_DEATH_COLS)
          boomBall:die()
        end

        -- level complete
        print("level complete!!")
        Sounds.beatLevel:play()
        Sounds.kickAndCrash:play()
        Sounds.freezeTimerLoop:stop()
        currPlayingMusic:stop()
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
      pUp:activate(p1)

      -- Special power-ups
      -- BOOM!
      if pUp.powerupType == constants.POWERUP_TYPES.LAVABOMB then
        local n=love.math.random(#lavaBalls/4)+1
        Sounds.lavabombExplode:play()
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
 local baseColour = colour[lineCols[levelNum%3]]

 --

 -- try pulsing lines w music a wee bit
 if gameState == constants.GAME_STATE.LVL_PLAY or 
    gameState == constants.GAME_STATE.LVL_INTRO or 
    gameState == constants.GAME_STATE.INFO or 
    gameState == constants.GAME_STATE.TITLE 
 then
    local PULSE_DUR = 0.6 -- seconds to fade out each pulse
    if timeSinceLastPulse >= 2 * SECONDS_PER_BEAT then
      timeSinceLastPulse = 0
    end
    local intensity = 1.0 + 0.3 * (1.0 - (timeSinceLastPulse / PULSE_DUR))
    intensity = math.max(0.7, intensity)
    -- TODO: TEMPORARILY DISABLED v
    intensity = 1.0 -- == NO PULSING EFFECT
    -------------
    local pulsingColour = {baseColour[1] * intensity, baseColour[2] * intensity, baseColour[3] * intensity}
    love.graphics.setColor(pulsingColour)
 else
    love.graphics.setColor(baseColour)
 end

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
      i*16-8 , 8 , 
      nil, nil, nil, 1, 1)
  end

  -- state-dependent overlays
  if gameState == constants.GAME_STATE.LVL_INTRO then
    local txtWidth = 450
    gfx.drawOutlineText("- LEVEL "..(levelNum-2).." -", 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    50,
    txtWidth,"center", colour[11],colour[6])

    -- intro countdown
    love.graphics.setColor(1, 1, 1, 6-txtSize)
    SPRITESHEET:drawCentered('INTRO_'..delayCounter,
                              constants.GAME_WIDTH/2, constants.GAME_HEIGHT/2, 
                              nil, nil, nil, txtSize, txtSize)

  elseif gameState == constants.GAME_STATE.LOSE_LIFE then
    if gameTimer== 0 then
      local txtWidth = 450
      gfx.drawOutlineText("- TIME'S UP -", 
      constants.GAME_WIDTH/2-(txtWidth/2) ,
      50,
      txtWidth,"center", colour[25])
    end
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
    (gameTimer<10 and gameState == constants.GAME_STATE.LVL_PLAY and math.random(2)==1) and colour[25] or colour[19])
    
  -- score
  gfx.drawOutlineText(string.format("%06d", p1.score),360 ,1 ,150,"right",colour[18])

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
      Scenes:initGameOver(p1)
      print("game over!!!")
      Sounds.gameOver:play()
      txtSize = 0
    end
  end
end

local function updateBalls(dt)

  -- Update Target Balls
  for index, tball in ipairs(targetBalls) do
    if gameState == constants.GAME_STATE.LVL_PLAY 
      and gamePowerUp ~= constants.POWERUP_TYPES.FREEZE then
      tball:applyVelocity(dt)
    end
    tball:update(dt)
  end
  -- Update Lava Balls
  for index, lball in ipairs(lavaBalls) do
    if gameState==constants.GAME_STATE.LVL_PLAY 
      and gamePowerUp ~= constants.POWERUP_TYPES.FREEZE then
      lball:applyVelocity(dt)
    end
    lball:update(dt)
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
      Sounds.freezeTimerLoop:stop()
      currPlayingMusic:setVolume(constants.MUSIC_VOLUME)
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

  -- Load save data
  local saveData = saveFile.load(constants.SAVE_FILENAME)
  highScore = tonumber(saveData.highScore or 0)
  highLevel = tonumber(saveData.highLevel or 0)
  

  -- Do splash screen first
  gameState = constants.GAME_STATE.SPLASH
  Scenes:initSplash()

  
  -- test shader effect
  bgEffect = moonshine(constants.GAME_WIDTH,constants.GAME_HEIGHT, 
                      moonshine.effects.vignette)

  -- Create player (once)
  p1 = Player.new({
    x = constants.GAME_WIDTH/2,
    y = constants.GAME_HEIGHT/2,
  })

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

  -- Splash/logo screen
  if gameState == constants.GAME_STATE.SPLASH then
    Sounds.splashIntro:play()
    Scenes:updateSplash(dt)
    if actionButtonPressed then 
      -- skip to the title screen
      gameState = constants.GAME_STATE.TITLE
      Sounds.splashIntro:stop()
      Sounds.titleLoop:play()
      Scenes:initTitle()
      resetPulsingLineTimes()
    end
   
  -- Title screen
  elseif gameState == constants.GAME_STATE.TITLE then
    updatePulsingLinesTimes(dt)
    Scenes:updateTitle(dt)
    if actionButtonPressed then 
      Scenes:initInstructions()
      gameState = constants.GAME_STATE.INFO
      Sounds.titleLoop:stop()
      Sounds.instructionsLoop:play()
      Sounds.menuBlip:play()
    end

  -- Instructions
  elseif gameState == constants.GAME_STATE.INFO then
    updatePulsingLinesTimes(dt)
    Scenes:updateInstructions(dt)
    -- Start game (level intro)
    if actionButtonPressed then 
      initLevel(levelNum)
      print("lvl intro")
      gameState = constants.GAME_STATE.LVL_INTRO
      Sounds.countdownTick:play() -- plays first tick
      resetPulsingLineTimes()
    end

  -- Level Intro
  elseif gameState == constants.GAME_STATE.LVL_INTRO then

    -- Allow player to move
    p1:update(dt)
    -- Update Lava + Target ballz (anim only)
    updateBalls(dt)

    updatePulsingLinesTimes(dt)

    txtSize = txtSize + .1175
    if txtSize > 6 then 
      txtSize = 0
      delayCounter = delayCounter - 1
      if delayCounter < 0 then
        gameState = constants.GAME_STATE.LVL_PLAY
        currPlayingMusic:play()
      elseif delayCounter == 0 then
        Sounds.countdownGo:play()
      else
        Sounds.countdownTick:play()
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

    -- Update pulsing lines times
    updatePulsingLinesTimes(dt)
    
    -- Decrease game timer
    gameTimerAtPrevFrame = gameTimer
    gameTimer = gameTimer - 0.016
    if gameTimer < 1 then
      gameTimer = 0 
      loseLife()
    end

    if gameTimer < 2 and gameTimerAtPrevFrame > 2 then
      Sounds.one:play()
    elseif gameTimer < 3 and gameTimerAtPrevFrame > 3 then
      Sounds.two:play()
    elseif gameTimer < 4 and gameTimerAtPrevFrame > 4 then
      Sounds.three:play()
    elseif gameTimer < 5 and gameTimerAtPrevFrame > 5 then
      Sounds.four:play()
    elseif gameTimer < 6 and gameTimerAtPrevFrame > 6 then
      Sounds.five:play()
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
      Sounds.lavabombExplode:playWithPitch(0.8 + 0.4 * math.random())
    end
    if love.math.random(15)==1 and #targetBalls > 0 then 
      -- kill target
      gfx.boom(targetBalls[1].x, targetBalls[1].y, 150, constants.PLAYER_DEATH_COLS)
      targetBalls[1]:die()
      table.remove(targetBalls, 1)
      Sounds.lavabombExplode:playWithPitch(0.8 + 0.4 * math.random())
    end

    Scenes:updateGameOver(dt)

    if actionButtonPressed then 
      -- TODO: Have a countdown that if player lets reach 0, go to Title

      -- Restart level
      p1.lives = livesAtLevelStart
      game.initLevel(levelNum)
      resetPulsingLineTimes()
    end

  end -- if gamestate


  -- update particles
  gfx.updateParticles(dt)

  -- Reset state for current frame
  actionButtonPressed = false
  lastMouseBtnDownState = mouseBtnDownState

  totalTime = totalTime + dt
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


  -- Splash/logo screen
  if gameState == constants.GAME_STATE.SPLASH then
    Scenes:drawSplash()
    return
  end

  -- Adjust/update shack positioning first (if any)
  gfx:updateShake()

  bgEffect(function()
    -- Draw background
    drawBackground()
    --love.graphics.rectangle("fill", 300,200, 200,200)
  end)


  -- Title screen
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