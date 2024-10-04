extends Node2D

@onready var FlyScene:PackedScene = load("res://games/flyswat/src/fly.tscn")
@onready var flySpawnLocation = $FlyPath/FlySpawnLocation
signal game_over(result)


var remaining := 25:
	set(value):
		remaining = value
		if remaining == 0:
			game_over.emit(1)


var timer = Timer.new()

var gameTimer = Timer.new()

var fly_spawn_time := .5

var fly_spawn_variance := 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer)
	add_child(gameTimer)
	timer.timeout.connect(spawn_fly)
	gameTimer.timeout.connect(func(): game_over.emit(0))
	timer.one_shot = true
	timer.start(fly_spawn_time)
	gameTimer.start(60)
	pass # Replace with function body.

func spawn_fly():
	var fly = FlyScene.instantiate()
	fly.died.connect(func(): remaining -= 1)
	flySpawnLocation.progress_ratio = randf()
	var dir = flySpawnLocation.rotation + PI / 2
	fly.position = flySpawnLocation.position
	fly.speed = randf_range(Fly.SPEED_RANGE[0],Fly.SPEED_RANGE[1])
	fly.velocity = Vector2(fly.speed,0.0).rotated(dir)
	fly.rotation = dir
	fly.arc = randf_range(0,.01)
	# randomize arc, angle, and speed
	add_child(fly)
	timer.start(fly_spawn_time + randf_range(0,fly_spawn_variance))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TimerLabel.text = str(gameTimer.time_left)
	$RemainingLabel.text = str(remaining)
	pass
