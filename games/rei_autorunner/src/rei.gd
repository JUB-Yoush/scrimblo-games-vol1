extends CharacterBody2D


var gravity_speed = 1.0
var jump_speed = 100.0
var in_air = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += gravity_speed
	if Input.is_action_just_pressed("spacebar"):
		velocity.y -= jump_speed
	move_and_slide()

