extends Area2D

var movement_function:Callable
var speed: float
var dir:Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var res = movement_function.call()
	speed = res[0]
	dir = res[1]
	pass
