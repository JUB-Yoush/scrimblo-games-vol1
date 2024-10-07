extends Node2D

@onready var player := $Player

var mushroomScene:PackedScene = load("res://games/mushroom/src/mushroom.tscn")
var collected_count = 0
var required = 10
var player_speed := 100.0
var spawn_range = 250
enum GAME_STATE {SETUP,PLAYING,DONE}

var current_game_state = GAME_STATE.SETUP
var dir:Vector2
var shroomTimer:Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(shroomTimer)
	shroomTimer.timeout.connect(
		func():
		var newShroom = mushroomScene.instantiate()
		newShroom.position.x = randf_range(0,spawn_range)
		newShroom.position.y = 0
		newShroom.collected.connect(func(): collected_count+=1)
		add_child(newShroom)
		shroomTimer.start(1)
		)
	shroomTimer.one_shot = true
	shroomTimer.start(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dir = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),0)
	player.velocity = dir * player_speed
	player.move_and_slide()
	pass
