extends Area2D

var movement_function:Callable
var speed: float
var dir:Vector2
var damage:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(func(): queue_free())
	add_to_group("bullets")
	area_entered.connect(on_area_entered)
	position = Vector2(1,0).rotated(rotation)
	dir = Vector2.RIGHT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += dir.rotated(rotation) * speed * delta

func on_area_entered(area:Area2D):
	if area.is_in_group("Heart"):
		queue_free()
		return
