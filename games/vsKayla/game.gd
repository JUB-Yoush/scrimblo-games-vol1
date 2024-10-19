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

var current_game_state:GAME_STATE = GAME_STATE.SETUP

signal command_completed
signal attack_over
var hp = 20
func _ready() -> void:
    clear_menu()
    %FightButton.pressed.connect( func(): command_selected(COMMANDS.FIGHT))
    %ActButton.pressed.connect(func(): command_selected(COMMANDS.ACT))
    %ItemButton.pressed.connect(func(): command_selected(COMMANDS.ITEM))
    %MercyButton.pressed.connect(func(): command_selected(COMMANDS.MERCY))
    end_turn()

func update_game_state(new_state:GAME_STATE):
    if new_state == GAME_STATE.DANMAKU:
        start_danmaku()
    current_game_state = new_state

func start_danmaku():
    #render the heart and the box
    await attack_over
    update_game_state(GAME_STATE.MENUS)
    pass

func start_turn():
    current_game_state = GAME_STATE.MENUS
    toggle_action_buttons(2)
    clear_menu()
    %FightButton.grab_focus()

func command_selected(command):
    awaiting_command = true
    toggle_action_buttons(0)
    clear_menu()

    if command == COMMANDS.FIGHT:
        %Cmd1.visible = true
        %Cmd1.text = "*Kayla"
    elif command == COMMANDS.ACT:
        populate_acts()
    elif command == COMMANDS.MERCY:
        %Cmd1.visible = true
        %Cmd1.text = "*Kayla"
    elif command == COMMANDS.ITEM:
        populate_items(0)

    %Cmd1.grab_focus()
    #while awaiting_command:
        #if Input.is_action_just_pressed("back_menu"):
            #start_turn()
            #return

    await command_completed
    awaiting_command = false
    end_turn()
    start_turn()

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
    current_game_state = GAME_STATE.DANMAKU
    toggle_action_buttons(0)
    enemy_turn()

func print_to_menu(text):
    pass

func enemy_turn():
    pattern1()
    attack_over.emit()


func pattern1():
    # drop from top of screen, at some point detonate and create spreads of 3 bullets to dodge
    # harder version: spread of 5
    var dropScene :PackedScene= load("res://games/vsKayla/bullet_patterns/drops.tscn")
    # get range that isn't above the heart box
    for i in range(5):
        var spawn_pos_x = randi_range(70,350)
        while spawn_pos_x > 150 and spawn_pos_x < 270:
            spawn_pos_x = randi_range(70,350)
        var drop = dropScene.instantiate()
        drop.global_position = Vector2(spawn_pos_x,0)
        add_child(drop)
        await get_tree().create_timer(.5).timeout
    await get_tree().create_timer(1).timeout


func pattern2():
    # zebra runs across the screen and the dust it kicks up rains down
    #harder version: more dust
    pass

func pattern3():
    # full screen spiral
    pass

func pattern4():

    pass

func pattern5():
    # full screen spiral
    pass

func pattern6():
    # full screen spiral
    pass