
local constants = require 'src/constants'
local gfx = require 'src/util/gfx'
local colour = require 'src/util/colour'
local SpriteSheet = require 'src/util/SpriteSheet'
local PowerUp = require 'src/entity/PowerUp'
local saveFile = require 'src/util/saveFile'
local Sounds = require 'src/util/sounds'
local Ball = require 'src/entity/Ball'


local delayCounter = 0
local levelScore = 0
local flashCount = 0
local startTime = 0
local duration = 0

local SECONDS_BETWEEN_LEVEL_SCORE_BLIPS = 0.06
local secondsSinceLastLevelScoreBlip = SECONDS_BETWEEN_LEVEL_SCORE_BLIPS
local SECONDS_BETWEEN_TIME_BONUS_BLIPS = 0.2
local secondsSinceLastTimeBonusBlip = SECONDS_BETWEEN_TIME_BONUS_BLIPS

local SPRITESHEET = SpriteSheet.new('assets/img/ballz-logo.png', {
  LOGO_1 = { 30, 8, 260, 72 },
  LOGO_2 = { 30, 90, 260, 90 },
})

local SPRITESHEET_SPLASH = SpriteSheet.new('assets/img/game-ui.png', {
  LOGO = { 136, 64, 51, 18},
})

Scenes = {
  -- Fields
  --Test = "hello"
}


--
-- Intro/Splash screen
--
function Scenes:initSplash()
  -- 
  startTime = love.timer.getTime()
end

function Scenes:updateSplash(dt)
  duration = love.timer.getTime()-startTime 
  if duration > 3.5 then
    -- load the title screen
    gameState = constants.GAME_STATE.TITLE
    Sounds.titleLoop:play()
    Scenes:initTitle()
  end
end

function Scenes:drawSplash()
  love.graphics.clear({0,0,0})
  local offset = math.sin(duration)*2
  --offset=1
  love.graphics.setColor(1,1,1, offset)
  SPRITESHEET_SPLASH:drawCentered(
      "LOGO", 
      math.floor(constants.GAME_WIDTH/2), 
      math.floor(constants.GAME_HEIGHT/2), 
      nil, nil, nil, 2, 2)
end

--
-- Title screen
--
function Scenes:initTitle()
  -- Create lava balls
  for i=1,10 do
    table.insert(lavaBalls, Ball.new({
      -- optional overloads
      id=i
    }))
  end
end

function Scenes:updateTitle(dt)
  --Update Lava Balls
  for index, lball in ipairs(lavaBalls) do
    lball:applyVelocity(dt)
    lball:update(dt)
  end
  
  flashCount = flashCount + 1 * dt
end

function Scenes:drawTitle()
  local txtWidth = constants.GAME_WIDTH+20
  local txtHeight = 50

  -- Draw Lava Balls
  for index, lball in ipairs(lavaBalls) do
    lball:draw()
  end

  -- score
  gfx.drawOutlineText(
    string.format("HIGH:%06d", highScore)..
    "                               Level "..string.format("%02d",highLevel).."",
    constants.GAME_WIDTH/2-(txtWidth/2)+1,1 ,
    txtWidth,"center",
    colour[9],colour[6])
  -- gfx.drawOutlineText(
  --   string.format("HIGH:%08d", highScore).."\nLevel "..highLevel.."",
  --   360,1 ,
  --   150,"right",
  --   colour[9],colour[6])


  love.graphics.setColor(1, 1, 1)
  SPRITESHEET:drawCentered(
      "LOGO_1", 
      constants.GAME_WIDTH/2, 
      70, 
      nil, nil, nil, 1, 1)

  local offset = math.abs(math.sin(love.timer.getTime() * 8))
  love.graphics.setColor(0.5+math.max(0.25,offset), math.max(0.25,offset), math.max(0.25,offset))
  SPRITESHEET:drawCentered(
      "LOGO_2", 
      constants.GAME_WIDTH/2, 
      160, 
      nil, nil, nil, 1, 1)

  gfx.drawOutlineText(' Code & Art                  SFX & Music', 
    constants.GAME_WIDTH/2-(txtWidth/2),
    242,
    txtWidth,"center",colour[12])
  gfx.drawOutlineText('Paul Nicholas                Jason Riggs', 
    constants.GAME_WIDTH/2-(txtWidth/2),
    260,
    txtWidth,"center")


  if math.floor(flashCount)%2 == 0 then
    gfx.drawOutlineText('- PRESS ANY KEY TO START -', 
      constants.GAME_WIDTH/2-(txtWidth/2),
      216,
      txtWidth,"center",colour[11])
  end
end


--
-- Instructions screen
--
function Scenes:initInstructions()
  flashCount = 0
end

function Scenes:updateInstructions(dt)
  flashCount = flashCount + 1 * dt
end

function Scenes:drawInstructions()
  local txtWidth = 600
  local txtHeight = 50
  local yPos = 10

  gfx.drawOutlineText('- INSTRUCTIONS -', 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    yPos,
    txtWidth,"center")
  
  yPos = yPos + 25
  
  gfx.drawOutlineText(
    "Absorb all the Green orbs\n"..
    "before the time runs out,\n"..
    "but remember...", 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    yPos,
    txtWidth,"center", colour[12],colour[15])

  yPos = yPos + 45
  
  gfx.drawOutlineText("THE BALLZ ARE LAVA!", 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    yPos,
    txtWidth,"center", colour[25],colour[6])

  yPos = yPos + 30
  
  gfx.drawOutlineText("POWER-UPS:", 
    100,
    yPos,
    txtWidth,"left")

  yPos = yPos + 29
  
  local desc={
    "One-time lava protection",
    "Extra time",
    "Destroy some lava ballz",
    "Freeze time for a moment",
    "Lava invincibility", 
    "Extra life",
  }

  for p=1,6 do
    local yPosPU = yPos + (p-1)*19
    love.graphics.setColor(1, 1, 1)
    PowerUp.SPRITESHEET:drawCentered(
      "P_"..p, 125, yPosPU-1, nil, nil, nil, 1, 1)
    gfx.drawOutlineText(
      desc[p],
      150,
      yPosPU-9,
      txtWidth,"left", colour[18])
  end

  yPos = yPos + 117
  
  if math.floor(flashCount)%2 == 0 then
    gfx.drawOutlineText('- PRESS ANY KEY TO START -', 
      constants.GAME_WIDTH/2-(txtWidth/2) ,
      yPos,
      txtWidth,"center",colour[11],colour[6])
  end
end


--
-- Level End screen
--
function Scenes:initLevelEnd(player)
  delayCounter = 1
  levelScore = player.targetsCollected * 100
  levelUpdateTotalTime = 0
end


function Scenes:updateLevelEnd(dt, player)
  delayCounter = delayCounter - 0.016
  secondsSinceLastLevelScoreBlip = secondsSinceLastLevelScoreBlip - dt
  secondsSinceLastTimeBonusBlip = secondsSinceLastTimeBonusBlip - dt
  if delayCounter <= 0 then
    if levelScore > 0 and secondsSinceLastLevelScoreBlip <= 0 then
      Sounds.scoreCountTick:play()
      secondsSinceLastLevelScoreBlip = SECONDS_BETWEEN_LEVEL_SCORE_BLIPS
    end
    if secondsSinceLastTimeBonusBlip <= 0 then
      Sounds.scoreCountTick:play()
      secondsSinceLastTimeBonusBlip = SECONDS_BETWEEN_TIME_BONUS_BLIPS
    end
    -- add level score to player score
    if (levelScore > 0) then
      player.score = player.score + 10 
      levelScore = levelScore - 10
    end
    -- add time bonus to score
    if (gameTimer > 0.1) then
      player.score = player.score + 1
      gameTimer = gameTimer - 0.1
    end
    -- go to next level?
    if (gameTimer < 0.1 and levelScore <= 0) then
      levelNum = levelNum + 1
      game.initLevel(levelNum)
      livesAtLevelStart = player.lives
    end
  end
end

function Scenes:drawLevelEnd()
  local txtWidth = 450
  local txtHeight = 50
  local yPos = 120

  gfx.drawOutlineText("- LEVEL "..(levelNum-2).." COMPLETE -", 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    yPos ,
    txtWidth,"center", colour[11],colour[6])

  gfx.drawOutlineText(
      "Level Score: "..levelScore.."\n"
      .."Time Bonus: "..(math.floor(gameTimer)*10).."\n", 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    yPos + 25 ,
    txtWidth,"center")
end

--
-- Game Over screen
--
function Scenes:initGameOver(player)
  flashCount = 0
  -- Save score (if new high score)
  if p1.score > highScore then
    highScore = p1.score
    highLevel = levelNum

    saveFile.save(constants.SAVE_FILENAME, {
      highScore = p1.score,
      highLevel = levelNum-2
    })
  end
end


function Scenes:updateGameOver(dt)
  flashCount = flashCount + 1 * dt
end

function Scenes:drawGameOver(player)
  local txtWidth = 450
  local txtHeight = 50
  gfx.drawOutlineText('FINAL SCORE: '..string.format("%06d", player.score), 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 - 10,
    txtWidth,"center")

  if flashCount > 1 and math.floor(flashCount)%2 == 0 then
    gfx.drawOutlineText('- PRESS ANY KEY TO RETRY -', 
      constants.GAME_WIDTH/2-(txtWidth/2) ,
      260,
      txtWidth,"center",colour[11],colour[6])
  end
end


return Scenes;