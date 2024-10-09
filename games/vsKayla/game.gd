extends Node2D
# set up game states
enum GAME_STATE {SETUP,TURN,DANMAKU,ENDED}

var current_game_state:GAME_STATE = GAME_STATE.SETUP

var hp = 20