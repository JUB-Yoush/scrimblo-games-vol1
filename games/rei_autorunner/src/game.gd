extends Node2D

var obstacleScene = load("res://games/rei_autorunner/src/obstacle.tscn")
var spawn_pos = Vector2(420,180)
var spawn_timer = Timer.new()
var spawn_time = 1.5
func _ready() -> void:
    add_child(spawn_timer)
    spawn_timer.one_shot = false
    spawn_timer.start(spawn_time)
    spawn_timer.timeout.connect(spawn_obby)

func _process(delta: float) -> void:

    pass

func spawn_obby():
    var obby = obstacleScene.instantiate()
    obby.position = spawn_pos
    obby.speed = 100
    add_child(obby)
    #
    pass