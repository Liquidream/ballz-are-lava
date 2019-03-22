
local constants = require 'src/constants'
local gfx = require 'src/util/gfx'

local delayCounter = 0
local levelScore = 0

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
  --print("drawTitle()..."..Scenes.Test)
end

function Scenes:updateInstructions(dt)
  --print("drawTitle()..."..Scenes.Test)
end

function Scenes:drawInstructions()
  local txtWidth = 450
  local txtHeight = 50
  gfx.drawOutlineText('TODO: INSTRUCTIONS SCREEN', 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 ,
    txtWidth,"center")
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
    end
  end
end

function Scenes:drawLevelEnd()
  local txtWidth = 450
  local txtHeight = 50
  gfx.drawOutlineText("- LEVEL "..(levelNum-2).." COMPLETE -\n"
      .."Level Score: "..levelScore.."\n"
      .."Time Bonus: "..(math.floor(gameTimer)*10).."\n", 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 ,
    txtWidth,"center")
end

--
-- Game Over screen
--
function Scenes:initGameOver()
  --print("drawTitle()..."..Scenes.Test)
end


function Scenes:updateGameOver(dt)
  --print("drawTitle()..."..Scenes.Test)
end

function Scenes:drawGameOver()
  local txtWidth = 450
  local txtHeight = 50
  gfx.drawOutlineText('- PRESS ANY KEY -', 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 - 10,
    txtWidth,"center")
end


return Scenes;