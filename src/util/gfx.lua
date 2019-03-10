-- Manage the render state and options

local constants = require 'src/constants'
local colour = require 'src/util/colour'

-- Screen dimensions are hardware-based (what's the size of the display device)
local SCREEN_WIDTH
local SCREEN_HEIGHT
-- Render dimenisions reflect how the game should be drawn to the canvas
local RENDER_SCALE
local RENDER_WIDTH
local RENDER_HEIGHT
local RENDER_X
local RENDER_Y
-- Camera shake-related
local shakeAmount = 0 -- how much to shake the screen (will stablise over time)
local shakeX = 0
local shakeY = 0

local particles={}

local font

local function init(self)
 font = love.graphics.newFont("assets/saxmono.ttf",18)
 font:setFilter("nearest", "nearest", 0 )
 love.graphics.setFont(font)
end

-- Recalibrate the render display, based on current display dimensions
-- (e.g. after change to/from Fullscreen)
local function updateDisplay(self)
 -- Screen dimensions are hardware-based (what's the size of the display device)
 local width, height = love.graphics.getDimensions()
 self.SCREEN_WIDTH = width
 self.SCREEN_HEIGHT = height
 self.RENDER_SCALE = math.floor(math.min(self.SCREEN_WIDTH / constants.GAME_WIDTH, self.SCREEN_HEIGHT / constants.GAME_HEIGHT))
 self.RENDER_WIDTH = self.RENDER_SCALE * constants.GAME_WIDTH
 self.RENDER_HEIGHT = self.RENDER_SCALE * constants.GAME_HEIGHT
 self.RENDER_X = (self.SCREEN_WIDTH - self.RENDER_WIDTH) / 2
 self.RENDER_Y = (self.SCREEN_HEIGHT - self.RENDER_HEIGHT) / 2
end



--
-- Special effects functions
--

-- screen shake
local function shake(self, amount)
  shakeAmount = amount
end

local function updateShake(self)
  -- Based on https://www.lexaloffle.com/bbs/?tid=28306
  --
  -- this function does the shaking
  -- first we generate two random numbers between -16 and +16
  self.shakeX=16-love.math.random()*32
  self.shakeY=16-love.math.random()*32
  
  
  -- then we apply the shake strength
  self.shakeX = self.shakeX * shakeAmount
  self.shakeY = self.shakeY * shakeAmount
      
  -- finally, fade out the shake reset to 0 when very low
  shakeAmount = shakeAmount * 0.95
  if (shakeAmount < 0.05) then 
    shakeAmount = 0 
  end
 end


-- Particles code
-- (based on https://www.lexaloffle.com/bbs/?tid=28260)

local function spawnParticle(_x,_y,_cols)
 -- create a new particle
 local new={}
 
 -- generate a random angle
 -- and speed
 local angle = love.math.random() * (2*math.pi)    -- rnd()
 local speed = 50+love.math.random()*150 -- rnd(2)
 
 new.x=_x --set start position
 new.y=_y --set start position
 -- set velocity based on
 -- speed and angle
 new.dx=math.sin(angle)*speed
 new.dy=math.cos(angle)*speed
 
 --add a random starting age
 --to add more variety
 new.age=math.floor(math.random(25))--25
  
 -- give each particle it's own color life
 new.cols = _cols
 
 --add the particle to the list
 table.insert(particles, new)
end

local function boom(_x,_y,_amount,_cols)
 -- create _amount particles at a location
 for i=0,_amount do
  spawnParticle(_x,_y,_cols)
 end
end

function updateParticles(dt)
 --iterate trough all particles
 for index, p in ipairs(particles) do
  --delete old particles
  --or if particle left 
  --the screen 
  if p.age > 75 
   or p.y > constants.GAME_HEIGHT
   or p.y < 0
   or p.x > constants.GAME_WIDTH
   or p.x < 0
   then
   table.remove(particles,index)
   --del(particles,p)
  else
   --move particle
   p.x=p.x+p.dx * dt
   p.y=p.y+p.dy * dt
   --age particle
   p.age=p.age+1
  end
 end
end

function drawParticles(self) 
 --iterate trough all particles
 local col
 for index, p in ipairs(particles) do
  --change color depending on age
  if p.age > 60 then col=p.cols[4]
  elseif p.age > 40 then col=p.cols[3]
  elseif p.age > 20 then col=p.cols[2]  
  else col=p.cols[1]--7 
  end
  --actually draw particle
  love.graphics.setColor(colour[col])
  love.graphics.rectangle("fill", 
    p.x + self.shakeX, 
    p.y + self.shakeY, 
    1, 1 )
  --pset(p.x,p.y,col)
 end
end






return {
 -- properties
 SCREEN_WIDTH = SCREEN_WIDTH,
 SCREEN_HEIGHT = SCREEN_HEIGHT,
 RENDER_SCALE = RENDER_SCALE,
 RENDER_WIDTH = RENDER_WIDTH,
 RENDER_HEIGHT = RENDER_HEIGHT,
 RENDER_X = RENDER_X,
 RENDER_Y = RENDER_Y,

 font = font,

 -- functions
 init = init,
 updateDisplay = updateDisplay,

 boom = boom,
 spawnParticle = spawnParticle,
 updateParticles = updateParticles,
 drawParticles = drawParticles,

 shake = shake, --function
 shakeX = shakeX,
 shakeY = shakeY,
 updateShake = updateShake,
}