extends Node2D

# set up game states
enum GAME_STATE {SETUP,MENUS,DANMAKU,ENDED}
enum COMMANDS {FIGHT,ACT,ITEM,MERCY}

var items = ["Bingus","M.Stew","Scrimbookie","scimblo"]
var curr_items= []
var actions = ["Check","Appeal","Antagonize","HR Talk"]

var current_game_state:GAME_STATE = GAME_STATE.SETUP
signal item_over
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
	toggle_action_buttons(0)
	if command == COMMANDS.FIGHT:
		clear_menu()
		%Cmd1.text = "*Kayla"
		%Cmd1.grab_focus()
	elif command == COMMANDS.MERCY:
		clear_menu()
		%Cmd1.text = "*Kayla"
		%Cmd1.grab_focus()
	elif command == COMMANDS.ITEM:
		clear_menu()
		populate_items(0)
		%Cmd1.grab_focus()
		#%Cmd1.pressed.connect(func(): use_item("item string goes here"))
		await item_over
	toggle_action_buttons(2)
	
func clear_menu():
	%MenuString.text = ""
	%Cmd1.text = ""
	%Cmd2.text = ""
	%Cmd3.text = ""
	%Cmd4.text = ""

func toggle_action_buttons(state):
	%FightButton.focus_mode = state
	%ActButton.focus_mode = state
	%ItemButton.focus_mode = state
	%MercyButton.focus_mode = state

func use_item(item_str):
	# if statements for different items 
	item_over.emit()
	pass

# the offset is the 4 items rendered
func populate_items(offset):
	offset = offset * 4
	var cmdBoxes = [%Cmd1,%Cmd2,%Cmd3,%Cmd4]
	for i in range(4):
		curr_items.append(items[offset + i])
		cmdBoxes[i].pressed.connect(func(): use_item(curr_items[i]))
		cmdBoxes[i].text = curr_items[i]
