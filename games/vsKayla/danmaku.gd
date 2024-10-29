extends Node2D


var attack_time = 5
var attackTimer = Timer.new()

signal attack_over

func _ready():
	attackTimer.one_shot = true
	add_child(attackTimer)
	attackTimer.timeout.connect(end)


func start(enemy_text):
	%MenuBox.visible = false
	%Heart.global_position = Vector2(214,128)
	visible = true
	%Heart.can_move = false
	%MenuCommands.visible = false
	if enemy_text != "":
		%Dialog.visible = true
		%Dialog.text = enemy_text
		await get_tree().create_timer(1).timeout
		%Dialog.visible = false
	%Heart.can_move = true
	pattern1.call()
	# find a more natural way to do this
	attackTimer.start(attack_time)


func end():
	%MenuBox.visible = true
	for bullet in get_tree().get_nodes_in_group("bullets"):
		bullet.queue_free()
	visible = false
	%MenuCommands.visible = true
	attack_over.emit()


func enemy_says(text):
	%Dialog.visible = true
	%Dialog.text = text
	await get_tree().create_timer(1).timeout
	%Dialog.visible = false


var pattern1 = func():
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
