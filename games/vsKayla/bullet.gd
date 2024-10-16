extends Area2D

var movement_function:Callable
var speed: float
var dir:Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	area_entered.connect(on_area_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = speed * dir * delta
	position += velocity

func on_area_entered(area:Area2D):
	if area.is_in_group("bullets"):
		return
