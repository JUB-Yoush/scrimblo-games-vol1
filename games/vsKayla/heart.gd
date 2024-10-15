extends CharacterBody2D

var speed = 100.0
var can_move = true
var dir = Vector2.ZERO

func _process(delta: float) -> void:
	if !can_move:
		return
	dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = speed * dir
	move_and_slide()
