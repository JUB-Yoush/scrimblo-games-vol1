extends CharacterBody2D


var gravity_speed = 7.0
var jump_speed = 250.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += gravity_speed
	if Input.is_action_just_pressed("spacebar") and is_on_floor():
		velocity.y -= jump_speed
	move_and_slide()

