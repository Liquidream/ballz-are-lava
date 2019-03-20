
local constants = require 'src/constants'


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
  love.graphics.setColor(1, 1, 1)
  local txtWidth = 450
  local txtHeight = 50
  love.graphics.printf('TODO: TITLE SCREEN', 
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
  love.graphics.setColor(1, 1, 1)
  local txtWidth = 450
  local txtHeight = 50
  love.graphics.printf('TODO: INSTRUCTIONS SCREEN', 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 ,
    txtWidth,"center")
end


--
-- Level End screen
--
function Scenes:initLevelEnd(player)
  --print("drawTitle()..."..Scenes.Test)
end


function Scenes:updateLevelEnd(dt)
  --print("drawTitle()..."..Scenes.Test)
end

function Scenes:drawLevelEnd()
  love.graphics.setColor(1, 1, 1)
  local txtWidth = 450
  local txtHeight = 50
  love.graphics.printf("- LEVEL "..(levelNum-2).." COMPLETE -", 
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
  love.graphics.setColor(1, 1, 1)
  local txtWidth = 450
  local txtHeight = 50
  love.graphics.printf('- PRESS ANY KEY -', 
    constants.GAME_WIDTH/2-(txtWidth/2) ,
    constants.GAME_HEIGHT/2 - 10,
    txtWidth,"center")
end


return Scenes;