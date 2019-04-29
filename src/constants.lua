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
local MUSIC_VOLUME = 0.5
--local DEBUG_MODE = true
local SAVE_FILENAME = "ballz-are-lava.dat"
local GAME_STATE = { SPLASH=0, TITLE=1, INFO=2, LVL_INTRO=3, LVL_PLAY=4, LVL_END=5, LOSE_LIFE=6, GAME_OVER=7 }
local BALL_TYPES = { LAVA=0, TARGET=1 }
local POWERUP_TYPES = { 
  NONE=0, 
  SHIELD=1, 
  TIME_EXTEND=2, 
  LAVABOMB=3, 
  FREEZE=4, 
  INVINCIBILITY=5, 
  EXTRA_LIFE=6, 
}
local POWERUP_STATE = { HIDDEN=0, VISIBLE=1, ACTIVE=2, DEAD=3 }
local PLAYER_MAX_SPEED = 200

local PLAYER_DEATH_COLS = {19,12,14,15} 
local LAVA_DEATH_COLS = {19,11,9,25}
local POWERUP_SHIELD_COLS = {[0]=23,22,21,20,19}
local POWERUP_INVINC_COLS = {[0]=7,8,9,10,11}

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
 SAVE_FILENAME = SAVE_FILENAME,
 GAME_STATE = GAME_STATE,
 BALL_TYPES = BALL_TYPES,
 MUSIC_VOLUME = MUSIC_VOLUME,
 POWERUP_TYPES = POWERUP_TYPES,
 POWERUP_STATE = POWERUP_STATE,
 PLAYER_MAX_SPEED = PLAYER_MAX_SPEED,
 PLAYER_DEATH_COLS = PLAYER_DEATH_COLS,
 LAVA_DEATH_COLS = LAVA_DEATH_COLS,
 POWERUP_SHIELD_COLS = POWERUP_SHIELD_COLS,
 POWERUP_INVINC_COLS = POWERUP_INVINC_COLS,
}