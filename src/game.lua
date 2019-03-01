local constants = require 'src/constants'
local Entity = require 'src/entity/Entity'
local listHelpers = require 'src/util/list'
local Player = require 'src/entity/Player'
local colour = require 'src/util/colour'

-- Entity vars
local entities


-- Entity methods
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




-- Main methods
local function load()
 -- Load save data
 -- local saveData = saveFile.load('quickdraw-blackjack.dat')

 -- Init vars
 scene = nil
 -- mostRoundsEncountered = saveData.best and tonumber(saveData.best) or 0
 -- hasSeenTutorial = saveData.hasSeenTutorial == 'true'
 
 -- -- Init sounds
 -- initSounds()

 -- Initialize game vars
 entities = {}
 -- -- Start at the title screen
 -- initTitleScreen(true)

 p1 = Player:spawn({
   -- rankIndex = cardProps.rankIndex,
   -- suitIndex = cardProps.suitIndex,
   x = constants.GAME_WIDTH/2,
   y = constants.GAME_HEIGHT/2,
   -- vr = math.random(-80, 80),
   -- hand = hand
 })
end

local function update(dt)
 -- backgroundCycleX = (backgroundCycleX + dt) % 12.0
 -- backgroundCycleY = (backgroundCycleY + dt) % 16.0
 -- -- Update all promises
 -- Promise.updateActivePromises(dt)

 p1:update()

 -- Update all entities
 local index, entity
 for index, entity in ipairs(entities) do
   -- if entity:checkScene(scene) and entity.isAlive then
   --   entity.timeAlive = entity.timeAlive + dt
   --   entity:update(dt)
   --   entity:countDownToDeath(dt)
   -- end
 end
 -- Remove dead entities
 entities = removeDeadEntities(entities)
 -- Sort entities for rendering
 table.sort(entities, function(a, b)
   return a.renderLayer < b.renderLayer
 end)
end

local function draw()
 -- Draw background
 
 love.graphics.clear(colour[26])
 --love.graphics.clear(0,0,0.25,1)

 p1:draw()

 -- local col, row
 -- for col = -2, math.ceil(constants.GAME_WIDTH / 40) + 2 do
 --   for row = -2, math.ceil(constants.GAME_HEIGHT / 20) + 2 do
 --     local x = 40 * col + (row % 2 == 0 and 0 or 6) + 80 * (backgroundCycleX / 12.0)
 --     local y = 20 * row  - 40 * (backgroundCycleY / 16.0)
 --     SPRITESHEET:drawCentered('BACKGROUND', x, y, 0, 0, 0, (row % 2 == 0 and 1.0 or -1.0), 1.0)
 --   end
 -- end
 -- -- Draw all entity shadows
 -- local index, entity
 -- for index, entity in ipairs(entities) do
 --   love.graphics.setColor(1, 1, 1, 1)
 --   entity:drawShadow()
 -- end
 -- Draw all entities
 for index, entity in ipairs(entities) do
   love.graphics.setColor(1, 1, 1, 1)
   entity:draw()
 end
end

return {
 load = load,
 update = update,
 draw = draw,
 --onMousePressed = onMousePressed
}