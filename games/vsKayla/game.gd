extends Node2D

# set up game states
enum GAME_STATE {SETUP,MENUS,DANMAKU,ENDED}
enum COMMANDS {FIGHT,ACT,ITEM,MERCY}

var items = ["Bingus","M.Stew"]

var current_game_state:GAME_STATE = GAME_STATE.SETUP

var hp = 20
@onready var actionButtons = $Control/VBoxContainer/ActionMenuMargin/ActionButtons


func _ready() -> void:
    # the heart can appear on the buttons when focused
    %FightButton.grab_focus()
    %FightButton.pressed.connect(command_selected,COMMANDS.FIGHT)

func command_selected(command):
    if command == COMMANDS.FIGHT:
        #render the kayla option, same w mercy
        pass
    pass