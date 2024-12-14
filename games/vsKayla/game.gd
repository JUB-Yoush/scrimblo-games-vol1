extends Node

var PROMPT = "BOSS"
var CONTROLS = "keeb"

# set up game states
enum GAME_STATE {SETUP,MENUS,DANMAKU,ENDED}
enum MENU_STATES {COMMANDS, MENU, CHOSEN}
enum COMMANDS {FIGHT,ACT,ITEM,MERCY}

var menu_state = MENU_STATES.COMMANDS

var items = ["* Bingus","* M.Soup","* Scrimbookie","* Pigeon"]
var curr_items = []
var acts = ["* Check","* Appeal","* Oppose","* HR Talk"]

var appeals = ["* You show Kayla a gif. \n It's spinning Rei Chiquita.","* You simply ask Kayla \n  for more social credit.","You turn to the audience \n (there is no audience)"]
var opposes = ["* You go on an impasioned rant about \n your disdain for audio-visualizers.","* You correct Kayla. \n  \"We aren't the Gaming Club,\" \n  \"We make games, Actually\"","* You try distracting Kayla from the \n knife orbiting you."]
var hrtalks = ["* you use the Macaroni Corpo Jargon\n technique."]
var start_turn_texts = ["* Smells of Scrimblo resedue.","* Your heart is filled with... pasta.","* Do Scrimblos dream of \n Sheep (2000) for the PSX?"]

var enemy_turn_text = ["Well Christina, I made it. dispite your directions.","quite fond of this scrimblo character"]
var opposing_turn_text = ["You've been ordering \na lot of Gino's Pizza."]
var start_turn_text = "* world is scrim blo blo blo"

var awaiting_command = false
var opposing = false
var scrimbookied = false
var sparable = false

var scrimblo = false
var pigeon_returned = false
var pigeon_waiting = false
var pigeon_turn:int

var fightbar_moving = false

@onready var cmdboxes = [%Cmd1,%Cmd2,%Cmd3,%Cmd4]
@onready var action_buttons =[%FightButton, %ActButton, %ItemButton, %MercyButton]
@onready var danmaku = $Danmaku

var social_credit = 100:
	set(value):
		if scrimbookied:
			value += 7
		social_credit = min(value,goal_credit)
		%SCreditBar.value = social_credit
		if social_credit == goal_credit:
			sparable = true
			credit_reached()

var goal_credit = 100
var turn_count = 1:
	set(value):
		turn_count = value
		if pigeon_waiting:
			if turn_count == pigeon_turn + 2:
				pigeon_returned = true
		if turn_count == deadline:
			out_of_time()
			pass
var deadline = 10

var max_hp := 20
var hp := 20:
	set(value):
		print(hp,value)
		hp =  clamp(value, 0,max_hp)
		%HPBar.value = hp
		if hp == 0:
			die()
		%HpLabel.text = str(hp) +"/"+ str(max_hp)


var current_game_state:GAME_STATE = GAME_STATE.SETUP

signal game_over(state)
signal command_completed
signal txb_adv
signal txb_back

func _ready() -> void:

	%AnimationPlayer.play("start")
	await %AnimationPlayer.animation_finished
	%AnimationPlayer.play("RESET")
	%MissPlayer.play("preset")
	await %AnimationPlayer.animation_finished
	%Cursor.position = Vector2(14,228)
	%AnimationPlayer.play("bob")
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
	if current_game_state == new_state:
		return
	# unload prev state
	if current_game_state == GAME_STATE.MENUS:
		clear_menu()
		toggle_action_buttons(0)

	# load new state
	if new_state == GAME_STATE.DANMAKU:
		var kayla_text = enemy_turn_text.pick_random()
		if opposing:
			kayla_text = opposing_turn_text.pick_random()
		danmaku.start(kayla_text,opposing)
	if new_state == GAME_STATE.MENUS:
		turn_count += 1
		start_turn()
	current_game_state = new_state

func start_turn():
	menu_state = MENU_STATES.COMMANDS
	# render the menu and the action buttons
	if opposing:
		print_to_menu("* Kayla is offended! \n Attacks are harder! \n use HR talk to diffuse!")
	elif pigeon_returned:
		if items.size() < 3:
			items.append("* M.Soup")
			print_to_menu("* The Pigeon returned from Cali! \n It hands you a bowl of Soup.")
		else:
			print_to_menu("* The Pigeon returned from Cali! \n ...but you don't have room for\n the Pigeon and the Soup.")
		pigeon_returned = false
		pigeon_waiting = false
		items.append("* Pigeon")
	else:
		print_to_menu(start_turn_texts.pick_random())

	clear_menu()
	toggle_action_buttons(2)
	%FightButton.grab_focus()
	update_cursor(%FightButton)
	await txb_back
	if menu_state == MENU_STATES.MENU:
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

		%Cmd1.pressed.connect(spare)
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
	%MissPlayer.play("knife")
	await  %MissPlayer.animation_finished
	%MissPlayer.play("miss")
	await  %MissPlayer.animation_finished
	%Knife.visible = false
	fightbar_moving = false
	%FightBar.visible = false
	# await or whatever
	command_completed.emit()
	%Textbox.texture = load("res://games/vsKayla/assets/textbox.png")
	pass

func spare():
	menu_state = MENU_STATES.CHOSEN
	if sparable:
		#turn her grey or whatever and sto animation
		%EnemySprite.modulate = "#717171"
		%AnimationPlayer.stop()
		print_to_menu("* YOU WON!.\n You earned 0 XP and 0 gold.")
		await txb_adv
		game_over.emit(true)
	else:
		print_to_menu("* Not enough Social Credit!")
		await txb_adv
		command_completed.emit()


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
	if item_str == "* M.Soup":
		hp += 15
		print_to_menu("* Made by Maddie. \n* Healed 15 HP.")
		await txb_adv
	elif item_str == "* Bingus":
		hp += 20
		print_to_menu("* It's mostly Ice. \n* Healed 20 HP.")
		await txb_adv
	elif item_str == "* Scrimbookie":
		scrimbookied = true
		print_to_menu("* You feel especially persuasive.\n  Extra Social Credit for 3 turns.")
		await txb_adv
	elif item_str == "* Pigeon":
		print_to_menu("* You tossed the Pigeon.\n It's flying to California. \n  It'll return in 2 business turns.")
		pigeon_returned = false
		pigeon_waiting = true
		pigeon_turn = turn_count
		await txb_adv
	rm_item(item_str)
	command_completed.emit()

func use_act(act_str):
	menu_state = MENU_STATES.CHOSEN
	if act_str == "* Check":
		print_to_menu("* Kayla: 50HP, 12ATK, 5DEF \n She runs lassonde clubs.")
		await txb_adv

	elif act_str == "* Appeal":
		print_to_menu(appeals.pick_random())
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
		textprompt(hrtalks.pick_random())
		if opposing:
			opposing = false
			print_to_menu(hrtalks[0])
			await txb_adv
			print_to_menu("* Situation Diffused!")
			await txb_adv
			social_credit += 20
		else:
			print_to_menu(hrtalks[0])
			await txb_adv
			print_to_menu("* Kayla looks indifferently")
			await txb_adv


	print('using action '+ act_str)
	command_completed.emit()



# the offset is the 4 items rendered
func populate_items(offset):
	print(items)
	for i in range(items.size()):
		#curr_items.append(items[offset + i])
		cmdboxes[i].visible = true
		cmdboxes[i].pressed.connect(func(): use_item(items[i]))
		cmdboxes[i].text = "  " + items[i]

func rm_item(item_str):
	print(items)
	for i in range(items.size()):
		if items[i] == item_str:
			items.remove_at(i)
			break
	print(items)


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
	clear_menu()
	# render one character at a time
	var output = ""
	for c in text:
		if menu_state == MENU_STATES.MENU:
			%MenuString.text = ''
			output = text
			break
		output += c
		%MenuString.text = output
		await get_tree().create_timer(.01).timeout


func take_damage(damage:int):
	hp -= damage
	pass

func out_of_time():
	print_to_menu("Deadline Reached! \n Insufficient social credit!")
	await txb_adv
	# make heart visible ig
	die()

func die():
	%AnimationPlayer.play("die")
	await %AnimationPlayer.animation_finished
	game_over.emit(0)


func credit_reached():

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
