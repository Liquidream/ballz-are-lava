-- Game dimensions are display-independent (i.e. not pixel-based)
local GAME_WIDTH = 512  -- 16:9 aspect ratio that fits nicely
local GAME_HEIGHT = 288 -- within the default Castle window size
local GAME_LEFT = 0
local GAME_RIGHT = GAME_WIDTH
local GAME_TOP = 0
local GAME_BOTTOM = GAME_HEIGHT
local GAME_MIDDLE_X = GAME_WIDTH / 2
local GAME_MIDDLE_Y = GAME_HEIGHT / 2
local DEBUG_MODE = false
--local DEBUG_MODE = true
local GAME_STATE = { TITLE=0, INFO=1, LVL_INTRO=2, LVL_PLAY=3, LVL_END=4, LOSE_LIFE=5, GAME_OVER=6 }
local BALL_TYPES = { LAVA=0, TARGET=1 }
local POWERUP_TYPES = { NONE=0, SHIELD=1, FREEZE=2, LAVABOMB=3, EXTRA_LIFE=4, TIME_EXTEND=5, INVINCIBILITY=6 }
local POWERUP_STATE = { HIDDEN=0, SHOWN=1, DEAD=2 }

local PLAYER_DEATH_COLS = {19,12,14,15} 
local LAVA_DEATH_COLS = {19,11,9,25} --{7,10,9,8} --p8 cols

return {
 GAME_WIDTH = GAME_WIDTH,
 GAME_HEIGHT = GAME_HEIGHT,
 GAME_LEFT = GAME_LEFT,
 GAME_RIGHT = GAME_RIGHT,
 GAME_TOP = GAME_TOP,
 GAME_BOTTOM = GAME_BOTTOM,
 GAME_MIDDLE_X = GAME_MIDDLE_X,
 GAME_MIDDLE_Y = GAME_MIDDLE_Y,
 DEBUG_MODE = DEBUG_MODE,
 GAME_STATE = GAME_STATE,
 BALL_TYPES = BALL_TYPES,
 POWERUP_TYPES = POWERUP_TYPES,
 POWERUP_STATE = POWERUP_STATE,
 PLAYER_DEATH_COLS = PLAYER_DEATH_COLS,
 LAVA_DEATH_COLS = LAVA_DEATH_COLS,
}