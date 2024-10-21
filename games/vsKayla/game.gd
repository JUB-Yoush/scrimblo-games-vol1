extends Node2D

# set up game states
enum GAME_STATE {SETUP,MENUS,DANMAKU,ENDED}
enum COMMANDS {FIGHT,ACT,ITEM,MERCY}

var items = ["*Bingus","*M.Stew","*Scrimbookie","*scimblo"]
var curr_items = []
var acts = ["*Check","*Appeal","*Antagonize","*HR Talk"]
var awaiting_command = false
@onready var cmdboxes = [%Cmd1,%Cmd2,%Cmd3,%Cmd4]
@onready var action_buttons =[%FightButton, %ActButton, %ItemButton, %MercyButton]
@onready var danmaku = $Danmaku

var social_credit = 0

var max_hp := 20
var hp := max_hp:
    set(value):
        hp = value
        if hp <= 0:
            game_over()
        %HpLabel.text = str(hp) +"/"+ str(max_hp)


var current_game_state:GAME_STATE = GAME_STATE.SETUP

signal command_completed

func _ready() -> void:
    danmaku.attack_over.connect(func(): update_game_state(GAME_STATE.MENUS))
    clear_menu()
    %FightButton.pressed.connect( func(): command_selected(COMMANDS.FIGHT))
    %ActButton.pressed.connect(func(): command_selected(COMMANDS.ACT))
    %ItemButton.pressed.connect(func(): command_selected(COMMANDS.ITEM))
    %MercyButton.pressed.connect(func(): command_selected(COMMANDS.MERCY))
    end_turn()

func update_game_state(new_state:GAME_STATE):
    print("update_game_state: ",current_game_state)
    # unload prev state
    if current_game_state == GAME_STATE.MENUS:
        clear_menu()
        toggle_action_buttons(0)

    # load new state
    if new_state == GAME_STATE.DANMAKU:
        danmaku.start()
    if new_state == GAME_STATE.MENUS:
        start_turn()
    current_game_state = new_state

func start_turn():
    # render the menu and the action buttons
    clear_menu()
    toggle_action_buttons(2)
    %FightButton.grab_focus()

func command_selected(command):
    awaiting_command = true
    toggle_action_buttons(0)
    clear_menu()

    if command == COMMANDS.FIGHT:
        %Cmd1.visible = true
        %Cmd1.text = "*Kayla"
        %Cmd1.pressed.disconnect()
        %Cmd1.pressed.connect(fight)
    elif command == COMMANDS.ACT:
        populate_acts()
    elif command == COMMANDS.MERCY:
        %Cmd1.visible = true
        %Cmd1.text = "*Kayla"
    elif command == COMMANDS.ITEM:
        populate_items(0)

    %Cmd1.grab_focus()

    await command_completed
    awaiting_command = false
    end_turn()

func fight():
    # do the timing minigame
    print('this is where youd do the timing game shell dodge every time so who even cares')
    # await or whatever
    end_turn()
    pass

func clear_menu():
    %MenuString.text = ""
    for box in cmdboxes:
        box.visible = false
        box.text = ""

func toggle_action_buttons(state):
    for btn in action_buttons:
        btn.focus_mode = state

func use_item(item_str):
    # if statements for different items
    print('using item '+ item_str)
    clear_menu()
    %MenuString.text = "you used " + item_str
    command_completed.emit()
    pass

func use_act(act_str):
    print('using action '+ act_str)
    %MenuString.text = "you used " + act_str
    print_to_menu("you used " + act_str)
    command_completed.emit()

# the offset is the 4 items rendered
func populate_items(offset):
    offset = offset * 4
    for i in range(4):
        curr_items.append(items[offset + i])
        cmdboxes[i].visible = true
        cmdboxes[i].pressed.connect(func(): use_item(curr_items[i]))
        cmdboxes[i].text = curr_items[i]

func populate_acts():
    for i in range(4):
        cmdboxes[i].visible = true
        cmdboxes[i].pressed.connect(func(): use_act(acts[i]))
        cmdboxes[i].text = acts[i]
    pass


func end_turn():
    update_game_state(GAME_STATE.DANMAKU)

func print_to_menu(text):
    pass


func take_damage(damage:int):
    hp -= damage
    pass

func game_over():
    #end the game
    pass
