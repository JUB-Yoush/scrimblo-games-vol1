extends CharacterBody2D


const SPEED = 3.0
var dir = Vector2.RIGHT
func _ready() -> void:
	dir = Vector2(0.5,0.4).normalized()
	velocity = SPEED * dir

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())