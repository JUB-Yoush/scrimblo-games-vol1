extends Node2D


var attack_time = 60
var attackTimer = Timer.new()
signal attack_over
signal pattern_over
var died = false

var opposing
func _ready():
	attackTimer.one_shot = true
	add_child(attackTimer)
	attackTimer.timeout.connect(end)


func start(enemy_text,_opposing):
	opposing = _opposing
	print('started')
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
	patterns.pick_random().call()
	#pattern2.call()
	# find a more natural way to do this
	await pattern_over
	end()



func end():
	if died:
		return
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


func heart_explode():
	if died:
		return
	died = true
	%Heart.can_hit = false
	%Heart.z_index = 1001
	%Heart.can_move = false
	get_parent().get_node('bg').z_index = 1000
	await get_tree().create_timer(1).timeout
	%Heart.hide()
	for i in range(randi_range(4,7)):
		var rigid := RigidBody2D.new()
		rigid.gravity_scale = .5
		rigid.global_position = %Heart.position
		var sprite = Sprite2D.new()
		sprite.z_index = 1001
		sprite.texture = load("res://games/vsKayla/assets/heart-shard.png")
		rigid.linear_velocity.x = randf_range(100,200) * [-1,1].pick_random()
		rigid.linear_velocity.y = randf_range(100,300)* [-1,1].pick_random()
		rigid.add_child(sprite)
		add_child(rigid)



var pattern1 := func():
	# drop from top of screen, at some point detonate and create spreads of 3 bullets to dodge
	# harder version: spread of 5
	var dropScene :PackedScene= load("res://games/vsKayla/bullet_patterns/drops.tscn")
	# get range that isn't above the heart box
	var count = 5
	if opposing:
		count = 7
	for i in range(count):
		var spawn_pos_x = randi_range(70,350)
		while spawn_pos_x > 150 and spawn_pos_x < 270:
			spawn_pos_x = randi_range(70,350)
		var drop = dropScene.instantiate()
		drop.global_position = Vector2(spawn_pos_x,0)
		add_child(drop)
		await get_tree().create_timer(.5).timeout
	await get_tree().create_timer(2).timeout
	pattern_over.emit()
	print('pattern over')


var pattern2 := func():
	var offsets = [0,30,60]
	var count = 6
	if opposing:
		count = 8
	for i in range(count):
		var stepperScene :PackedScene = load("res://games/vsKayla/bullet_patterns/stepper.tscn")
		var stepper1 = stepperScene.instantiate()
		var stepper2 = stepperScene.instantiate()
		add_child(stepper1)
		add_child(stepper2)
		var offset1 = offsets.pick_random()
		var offset2 = offsets.pick_random()
		while offset1 == offset2:
			offset1 = offsets.pick_random()
			offset2 = offsets.pick_random()
		stepper1.global_position = Vector2(170,95)
		stepper2.global_position = Vector2(170,95)
		stepper1.global_position.x += offset1
		stepper2.global_position.x += offset2
		stepper1.drop()
		stepper2.drop()
		await stepper1.dropped
		print('stepper dropped')
		await get_tree().create_timer(.1).timeout
		stepper1.queue_free()
		stepper2.queue_free()
	pattern_over.emit()
	print('pattern over')


var pattern3 = func():
	var spiralSource = load("res://games/vsKayla/bullet_patterns/spiral_source.tscn").instantiate()
	var spinBulletScene :PackedScene = load("res://games/vsKayla/bullet_spin.tscn")
	add_child(spiralSource)
	spiralSource.global_position = Vector2(216,80)
	var rot_mod = randf_range(.6,.7)
	var b_speed = randf_range(80,100)
	for i in range(20):
		spiralSource.rotate(rot_mod)
		spiralSource.position.y += 6
		b_speed += 5
		if spiralSource.rotation > PI or spiralSource.rotation < 0:
			#rot_mod = (rot_mod + 0.02)
			pass
		for j in range(2):
			var mod = 1
			if j == 1:
				mod = -1
			var b = spinBulletScene.instantiate()
			add_child(b)
			b.speed = b_speed * mod
			b.damage = 1
			b.global_position = spiralSource.global_position
			b.rotation = spiralSource.rotation
		await get_tree().create_timer(.3).timeout
	await get_tree().create_timer(1).timeout
	pattern_over.emit()

var pattern4 = func():
	# stop them from bunching up at the beginning
	var ball_count = 3
	var start_pos = 190
	for i in range(ball_count):
		var ball = load("res://games/vsKayla/bullet_patterns/bullet_ball.tscn").instantiate()
		add_child(ball)
		ball.dir = Vector2((.5 + randf_range(.1,.9))*[-1,1].pick_random(),1).normalized()
		ball.position = Vector2(start_pos + (30 * i),104)
	await get_tree().create_timer(6).timeout
	pattern_over.emit()

func pattern5():
	# full screen spiral
	pass


var patterns = [pattern1,pattern2,pattern3,pattern4]