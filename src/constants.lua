-- Game dimensions are display-independent (i.e. not pixel-based)
local GAME_WIDTH = 512 --640 --320
local GAME_HEIGHT = 288 --360 --180
local GAME_LEFT = 0
local GAME_RIGHT = GAME_WIDTH
local GAME_TOP = 0
local GAME_BOTTOM = GAME_HEIGHT
local GAME_MIDDLE_X = GAME_WIDTH / 2
local GAME_MIDDLE_Y = GAME_HEIGHT / 2

local BALL_TYPES = { LAVA=0, TARGET=1 }

local PLAYER_DEATH_COLS = {12,12,14,15} --{19,12,13,14,15}
local LAVA_DEATH_COLS = {7,10,9,8}

return {
 GAME_WIDTH = GAME_WIDTH,
 GAME_HEIGHT = GAME_HEIGHT,
 GAME_LEFT = GAME_LEFT,
 GAME_RIGHT = GAME_RIGHT,
 GAME_TOP = GAME_TOP,
 GAME_BOTTOM = GAME_BOTTOM,
 GAME_MIDDLE_X = GAME_MIDDLE_X,
 GAME_MIDDLE_Y = GAME_MIDDLE_Y,
 
 BALL_TYPES = BALL_TYPES,
 PLAYER_DEATH_COLS = PLAYER_DEATH_COLS,
 LAVA_DEATH_COLS = LAVA_DEATH_COLS,
}