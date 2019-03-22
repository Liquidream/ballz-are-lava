
local constants = require 'src/constants'
local gfx = require 'src/util/gfx'
local colour = require 'src/util/colour'
local PowerUp = require 'src/entity/PowerUp'

local delayCounter = 0
local levelScore = 0
local flashCount = 0

Scenes = {
  -- Fields
  --Test = "hello"
}

--
-- Title screen
--
function Scenes:initTitle()
  --print("drawTitle()..."..Scenes.Test)
end

function Scenes:updateTitle(dt)
  --print("drawTitle()..."..Scenes.Test)
end

function Scenes:drawTitle()
  local txtWidth = 450
  local txtHeight = 50
  gfx.drawOutlineText('TODO: TITLE SCREEN', 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 ,
    txtWidth,"center")
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
    "Absorb all the Green orbs before the time runs out,\n"..
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

  yPos = yPos + 30
  
  local desc={
    "One-time lava protection",
    "Extra time",
    "Destroy some lava ballz",
    "Freeze time for a moment",
    "Lava invincibility", 
    "Extra life",
  }

  for p=1,6 do
    local yPosPU = yPos + (p-1)*20
    love.graphics.setColor(1, 1, 1)
    PowerUp.SPRITESHEET:drawCentered(
      "P_"..p, 125, yPosPU, nil, nil, nil, 1, 1)
    gfx.drawOutlineText(
      desc[p],
      150,
      yPosPU-7,
      txtWidth,"left", colour[18])
  end

  yPos = yPos + 120
  
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
  --print("drawTitle()..."..Scenes.Test)
  delayCounter = 1
  levelScore = player.targetsCollected * 100
end


function Scenes:updateLevelEnd(dt, player)
  --print("drawTitle()..."..Scenes.Test)
  delayCounter = delayCounter - 0.016
  if delayCounter <= 0 then
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
  local yPos = 125

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
function Scenes:initGameOver()
  flashCount = 0
end


function Scenes:updateGameOver(dt)
  flashCount = flashCount + 1 * dt
end

function Scenes:drawGameOver(player)
  local txtWidth = 450
  local txtHeight = 50
  gfx.drawOutlineText('FINAL SCORE: '..string.format("%08d", player.score), 
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