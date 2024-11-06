extends CharacterBody2D


var speed = 1.3
var dir = Vector2.RIGHT
@onready var area = $BallArea
func _ready() -> void:
	velocity = speed * dir
	area.add_to_group("bullets")
	add_to_group("bullets")

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())