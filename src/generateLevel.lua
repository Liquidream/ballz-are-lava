local constants = require 'src/constants'
local listHelpers = require 'src/util/list'



local function generateLevelDifficulty(levelNumber)
 local allowAces = levelNumber >= 9
 local numLavaBalls = 16 --8
 local numTargetBalls = 10
 local lavaBallsSpeed = 5

 return {
  numLavaBalls = numLavaBalls,
  lavaBallsSpeed = lavaBallsSpeed,
  numTargetBalls = numTargetBalls,
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
  print('  numLavaBalls = '..numLavaBalls)
  print('  numTargetBalls = '..numTargetBalls)
  print('  lavaBallsSpeed = '..lavaBallsSpeed)
  print('  enablePowerUpShield = '..(enablePowerUpShield and 'true' or 'false'))

  return {
   numLavaBalls = numLavaBalls,
   lavaBallsSpeed = lavaBallsSpeed,
   numTargetBalls = numTargetBalls,
  }
end

return generateLevel
