local constants = require 'src/constants'
local graphics = require 'src/util/graphics'
local Entity = require 'src/entity/Entity'
local listHelpers = require 'src/util/list'
local Player = require 'src/entity/Player'
local Ball = require 'src/entity/Ball'
local colour = require 'src/util/colour'
local generateLevel = require 'src/generateLevel'
local collision = require 'src/util/collision'

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

-- mouse pos (in game co-ordinates)
mouseX=nil
mouseY=nil



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
 lavaBalls = {}
 targetBalls = {}
 -- -- Start at the title screen
 -- initTitleScreen(true)

 -- Create player
 p1 = Player:spawn({
   x = constants.GAME_WIDTH/2,
   y = constants.GAME_HEIGHT/2,
 })

 -- Generate a new level
 local level = generateLevel(1)

 -- Create lava balls
 for i=1,level.numLavaBalls do
  table.insert(lavaBalls, Ball:spawn({
   -- optional overloads
  }))
 end

  -- Create target balls
  for i=1,level.numTargetBalls do
   table.insert(targetBalls, Ball:spawn({
    -- optional overloads
    ball_type=constants.BALL_TYPES.TARGET,
   }))
  end


end

local function update(dt)
 -- backgroundCycleX = (backgroundCycleX + dt) % 12.0
 -- backgroundCycleY = (backgroundCycleY + dt) % 16.0
 -- -- Update all promises
 -- Promise.updateActivePromises(dt)
 
 -- Update mouse position
 -- get the position of the mouse
 mouseX, mouseY = love.mouse.getPosition()
 -- adjust mouse position for scale
 mouseX = (mouseX-graphics.RENDER_X) / graphics.RENDER_SCALE
 mouseY = (mouseY-graphics.RENDER_Y) / graphics.RENDER_SCALE

 -- Update all entities
 local index, entity
 for index, entity in ipairs(entities) do
  if entity:checkScene(scene) and entity.isAlive then
   entity.timeAlive = entity.timeAlive + dt
   entity:update(dt)
   entity:countDownToDeath(dt)
  end
 end
 
 -- Update player (if alive)
 if p1.isAlive then
  p1:update()
  -- check player collisions
  -- lava balls
  for index, lball in ipairs(lavaBalls) do
   if collision.objectsAreTouching(p1,lball)
    and p1.timeAlive>1 then
    -- TODO: Player death (unless invinc/shield)
    p1:die()
    print("dead!!")
   end
  end
  -- target balls
  for index, tball in ipairs(targetBalls) do
   if collision.objectsAreTouching(p1,tball) then
    tball:die()
   end
  end 
 else
  -- Player died
  p1.deathCount = p1.deathCount-1
  if p1.deathCount <= 0 then
   -- Restart Game
   -- (TODO: proper death, etc.)
   load()
  end
 end

 -- Remove dead entities
 entities = removeDeadEntities(entities)
 -- Sort entities for rendering
 table.sort(entities, function(a, b)
   return a.renderLayer < b.renderLayer
 end)
end

local function draw_background()
 local gridSize=16
 -- navy
 love.graphics.clear(colour[26])
 love.graphics.setColor(colour[24])
 -- red
 -- love.graphics.clear(colour[26])
 -- love.graphics.setColor(colour[6])
 --
 for x=0, constants.GAME_WIDTH, gridSize do
   love.graphics.line(x,0,x,constants.GAME_HEIGHT)
 end
 for y=0, constants.GAME_HEIGHT, gridSize do
   love.graphics.line(0,y,constants.GAME_WIDTH,y)
 end
end

local function draw()
 -- Draw background
 draw_background()

 if p1.isAlive then
  p1:draw()
 else
  -- todo: draw death
 end

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
  love.graphics.setColor(1, 1, 1)
   entity:draw()
 end


 -- Draw game boundary
 -- love.graphics.setColor(colour[27])
 -- love.graphics.rectangle("line", 0, 0, constants.GAME_WIDTH, constants.GAME_HEIGHT )
 
end



return {
 load = load,
 update = update,
 draw = draw,
 draw_background = draw_background,
 --onMousePressed = onMousePressed
}