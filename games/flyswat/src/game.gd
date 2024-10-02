extends Node2D

@onready var FlyScene:PackedScene = load("res://games/flyswat/src/fly.tscn")
@onready var flySpawnLocation = $FlyPath/FlySpawnLocation

var remaining := 25

var timer = Timer.new()

var gameTimer = Timer.new()

var fly_spawn_time := 0.5

var fly_spawn_variance := 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(spawn_fly)
	timer.start(fly_spawn_time)
	pass # Replace with function body.

func spawn_fly():
	var fly = FlyScene.instantiate()
	flySpawnLocation.progress_ratio = randf()
	var dir = flySpawnLocation.rotation + PI / 2
	fly.position = flySpawnLocation.position
	# randomize arc, angle, and speed
	#add_child(fly)

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
