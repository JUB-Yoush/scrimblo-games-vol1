extends Node2D

# set up game states
enum GAME_STATE {SETUP,MENUS,DANMAKU,ENDED}
enum COMMANDS {FIGHT,ACT,ITEM,MERCY}

var items = ["Bingus","M.Stew","Scrimbookie"]
var actions = ["Check","Appeal","Antagonize"]

var current_game_state:GAME_STATE = GAME_STATE.SETUP

var hp = 20
func _ready() -> void:
    clear_menu()
    # the heart can appear on the buttons when focused
    %FightButton.grab_focus()
    %FightButton.pressed.connect( func(): command_selected(COMMANDS.FIGHT))
    %ActButton.pressed.connect(func(): command_selected(COMMANDS.ACT))
    %ItemButton.pressed.connect(func(): command_selected(COMMANDS.ITEM))
    %MercyButton.pressed.connect(func(): command_selected(COMMANDS.MERCY))

func command_selected(command):
    if command == COMMANDS.FIGHT:
        clear_menu()
        %Cmd1.text = "*Kayla"
        %Cmd1.grab_focus()
        unfocus_action_buttons()
    elif command == COMMANDS.MERCY:
        clear_menu()
        %Cmd1.text = "*Kayla"
        %Cmd1.grab_focus()
        unfocus_action_buttons()
    elif command == COMMANDS.ITEM:
        clear_menu()
        %Cmd1.text = "*Kayla"
        %Cmd1.grab_focus()
        %Cmd1.pressed.connect(func(): item_used("item string goes here"))
        unfocus_action_buttons()

func clear_menu():
    %MenuString.text = ""
    %Cmd1.text = ""
    %Cmd2.text = ""
    %Cmd3.text = ""
    %Cmd4.text = ""

func unfocus_action_buttons():
    %FightButton.focus_mode = 0
    %ActButton.focus_mode = 0
    %ItemButton.focus_mode = 0
    %MercyButton.focus_mode = 0

func item_used():
    pass