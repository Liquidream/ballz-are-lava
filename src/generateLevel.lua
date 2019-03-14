local constants = require 'src/constants'
local listHelpers = require 'src/util/list'



local function generateLevelDifficulty(levelNumber)
 -- set the rnd gen seed for level
 love.math.setRandomSeed(levelNumber)

 local allowAces = levelNumber >= 9
  -- calculate target + enemys
 local numLavaBalls = math.floor((levelNumber+1)*1.5)  -- increase enemies by constant factor
 local numTargetBalls = (levelNumber < 7) and math.floor(1.5*(levelNumber+1)) or 10 -- cap # targets to 10
 local numPowerUps = math.floor(levelNumber*.5)
 -- local numLavaBalls = 16
 -- local numTargetBalls = 10
 local lavaBallsSpeed = 5

 return {
  numLavaBalls = numLavaBalls,
  lavaBallsSpeed = lavaBallsSpeed,
  numTargetBalls = numTargetBalls,
  numPowerUps = numPowerUps,
  enablePowerUpShield = enablePowerUpShield,
  enablePowerUpFreeze = enablePowerUpFreeze,
  enablePowerUpLavabomb = enablePowerUpLavabomb,
  enablePowerUp1up = enablePowerUp1up,
  enablePowerUpTimeExtend = enablePowerUpTimeExtend,
  enablePowerUpInvincibility = enablePowerUpInvincibility,
  
  
 }
end

local generateLevel
generateLevel = function(levelNumber)
  print('Generating level '..levelNumber)
  local difficulty = generateLevelDifficulty(levelNumber)
  -- Calculate number of lava balls (and difficulty)
  local numLavaBalls = difficulty.numLavaBalls
  local numTargetBalls = difficulty.numTargetBalls
  local lavaBallsSpeed = difficulty.lavaBallsSpeed
  local numPowerUps = difficulty.numPowerUps
  print('  numLavaBalls = '..numLavaBalls)
  print('  numTargetBalls = '..numTargetBalls)
  print('  lavaBallsSpeed = '..lavaBallsSpeed)
  print('  numPowerUps = '..numPowerUps)
  --print('  enablePowerUpShield = '..(enablePowerUpShield and 'true' or 'false'))

  return {
   numLavaBalls = numLavaBalls,
   lavaBallsSpeed = lavaBallsSpeed,
   numTargetBalls = numTargetBalls,
   numPowerUps = numPowerUps,
  }
end

return generateLevel
