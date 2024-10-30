extends Node

# set up game states
enum GAME_STATE {SETUP,MENUS,DANMAKU,ENDED}
enum MENU_STATES {COMMANDS, MENU, CHOSEN}
enum COMMANDS {FIGHT,ACT,ITEM,MERCY}

var menu_state = MENU_STATES.COMMANDS

var items = ["* Bingus","* M.Stew","* Scrimbookie","* Scimblo"]
var curr_items = []
var acts = ["* Check","* Appeal","* Oppose","* HR Talk"]

var appeals = ["* You show Kayla a gif. \n* It's spinning Rei Chiquita.","* You simply ask for social credit."]
var opposes = ["* You say the phrase \"Scrimblo\". \n* 128 times.","* You correct Kayla. \n* \"We aren't the Gaming Club,\" \n* \"We make games, Actually\""]
var hrtalks = ["* You use your strongest corportate jargon."]

var enemy_turn_text = "this is what I have to say"
var start_turn_text = "* world is scrim blo blo blo"

var awaiting_command = false
var opposing = false
var scrimbookied = false
var sparable = false

var fightbar_moving = false

@onready var cmdboxes = [%Cmd1,%Cmd2,%Cmd3,%Cmd4]
@onready var action_buttons =[%FightButton, %ActButton, %ItemButton, %MercyButton]
@onready var danmaku = $Danmaku

var social_credit = 0:
	set(value):
		social_credit = value
		%SCreditBar.value = value
		if social_credit == goal_credit:
			credit_reached()

var goal_credit = 100
var turn_count = 1:
	set(value):
		turn_count = value
		if turn_count == deadline:
			game_over()
			pass
var deadline = 20

var max_hp := 20
var hp := max_hp:
	set(value):
		hp =  min(value, max_hp)
		%HPBar.value = hp
		if hp <= 0:
			game_over()
		%HpLabel.text = str(hp) +"/"+ str(max_hp)


var current_game_state:GAME_STATE = GAME_STATE.SETUP

signal command_completed
signal txb_adv
signal txb_back

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(update_cursor)
	danmaku.attack_over.connect(func(): update_game_state(GAME_STATE.MENUS))
	clear_menu()
	%FightButton.pressed.connect( func(): command_selected(COMMANDS.FIGHT))
	%ActButton.pressed.connect(func(): command_selected(COMMANDS.ACT))
	%ItemButton.pressed.connect(func(): command_selected(COMMANDS.ITEM))
	%MercyButton.pressed.connect(func(): command_selected(COMMANDS.MERCY))
	start_turn()

func update_cursor(control:Control):
	%Cursor.visible = true
	%Cursor.global_position = control.global_position
	if control is Button:
		%Cursor.position.x += 8
		%Cursor.position.y += 8
	else:
		%Cursor.position.x += 10
		%Cursor.position.y += 12

func update_game_state(new_state:GAME_STATE):
	print("update_game_state: ",current_game_state)
	# unload prev state
	if current_game_state == GAME_STATE.MENUS:
		clear_menu()
		toggle_action_buttons(0)

	# load new state
	if new_state == GAME_STATE.DANMAKU:
		danmaku.start(enemy_turn_text)
	if new_state == GAME_STATE.MENUS:
		turn_count += 1
		start_turn()
	current_game_state = new_state

func start_turn():
	menu_state = MENU_STATES.COMMANDS
	# render the menu and the action buttons
	clear_menu()
	print_to_menu(start_turn_text)
	toggle_action_buttons(2)
	%FightButton.grab_focus()
	update_cursor(%FightButton)
	await txb_back
	if menu_state != MENU_STATES.CHOSEN:
		clear_menu()
		start_turn()

func command_selected(command):
	menu_state = MENU_STATES.MENU
	# going backwards in menus should happen
	awaiting_command = true
	toggle_action_buttons(0)
	clear_menu()
	if command == COMMANDS.FIGHT:
		%Cmd1.visible = true
		%Cmd1.text = "  * Kayla"
		%Cmd1.pressed.connect(fight)
	elif command == COMMANDS.ACT:
		populate_acts()
	elif command == COMMANDS.MERCY:
		%Cmd1.visible = true
		%Cmd1.text = "  * Kayla"

		%Cmd1.pressed.connect(fight)
	elif command == COMMANDS.ITEM:
		populate_items(0)

	%Cmd1.grab_focus()

	await command_completed
	awaiting_command = false
	clear_menu()
	end_turn()

func fight():
	clear_menu()
	menu_state = MENU_STATES.CHOSEN
	%Textbox.texture = load("res://games/vsKayla/assets/attackscale.png")
	%FightBar.visible = true
	%FightBar.position.x = 370
	fightbar_moving = true
	# do the timing minigame
	await txb_adv
	%Knife.visible = true
	for i in range(6):
		%FightBar.texture = load("res://games/vsKayla/assets/fightbaralt.png")
		%Knife.frame = i
		await get_tree().create_timer(.1).timeout
		%FightBar.texture = load("res://games/vsKayla/assets/fightbar.png")
		await get_tree().create_timer(.1).timeout
	%Knife.visible = false
	fightbar_moving = false
	%FightBar.visible = false
	# await or whatever
	command_completed.emit()
	%Textbox.texture = load("res://games/vsKayla/assets/textbox.png")
	pass

func clear_menu():
	%Cursor.visible = false
	%Dialog.text = ""
	%MenuString.text = ""
	for box in cmdboxes:
		box.visible = false
		box.text = ""
		# reset signals
		for sig in box.get_signal_connection_list("pressed"):
			box.pressed.disconnect(sig["callable"])
			pass

func toggle_action_buttons(state):
	for btn in action_buttons:
		btn.focus_mode = state

func use_item(item_str):

	menu_state = MENU_STATES.CHOSEN
	clear_menu()
	if item_str == "* M.Stew":
		hp += 20
		print_to_menu("* You drank Stew sent by Maddie \n* Healed 20 HP")
		await txb_adv
	elif item_str == "* Bingus":
		hp += 10
		print_to_menu("* It's kinda melted. \n* Healed 20 HP")
		await txb_adv
	elif item_str == "* Scrimbookie":
		scrimbookied = true
		print_to_menu("* You feel especially persuasive.\n * Extra Social Credit for 3 turns")
		await txb_adv
	elif item_str == "* Pigeon":
		scrimbookied = true
		print_to_menu("* You feel especially persuasive.\n * Extra Social Credit for 3 turns")
		await txb_adv
	command_completed.emit()

func use_act(act_str):
	menu_state = MENU_STATES.CHOSEN
	if act_str == "* Check":
		print_to_menu("Kayla: 1HP, 1ATK, 1DEF \n She runs lassonde clubs.")
		await txb_adv

	elif act_str == "* Appeal":
		print_to_menu(appeals[0])
		social_credit += 5
		await txb_adv

	elif act_str == "* Oppose":
		if opposing:
			print('guh')
		else:
			opposing = true
			print_to_menu(opposes[1])
			await txb_adv
			start_turn_text = "* kayla is feeling particularly \n* critical of your club"

	elif act_str == "* HR Talk":
		textprompt(hrtalks[0])
		if opposing:
			opposing = false
			print_to_menu(hrtalks[0])
			await txb_adv
			print_to_menu("Situation Diffused!")
			await txb_adv
			social_credit += 15
			start_turn_text = "scrimblo permiates the air"
		else:
			print_to_menu(hrtalks[0])
			await txb_adv
			print_to_menu("Kayla looks indifferently")
			await txb_adv


	print('using action '+ act_str)
	command_completed.emit()



# the offset is the 4 items rendered
func populate_items(offset):
	offset = offset * 4
	for i in range(4):
		curr_items.append(items[offset + i])
		cmdboxes[i].visible = true
		cmdboxes[i].pressed.connect(func(): use_item(curr_items[i]))
		cmdboxes[i].text = "  " + curr_items[i]

func populate_acts():
	for i in range(4):
		cmdboxes[i].visible = true
		cmdboxes[i].pressed.connect(func(): use_act(acts[i]))
		cmdboxes[i].text = "  " +acts[i]
	pass


func end_turn():
	update_game_state(GAME_STATE.DANMAKU)

func textprompt(text):
	print_to_menu(text)
	await txb_adv

func print_to_menu(text):
	# will b more sophisiticated later
	clear_menu()
	%MenuString.text = text


func take_damage(damage:int):
	hp -= damage
	pass

func game_over():
	#end the game
	pass

func credit_reached():
	# kayla is sparable
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		txb_adv.emit()
	elif event.is_action_pressed("ui_cancel"):
		txb_back.emit()
		pass


func _process(delta):
	if fightbar_moving:
		var barSpeed = -175
		%FightBar.position.x += barSpeed * get_process_delta_time()
	await txb_adv
	fightbar_moving = false
