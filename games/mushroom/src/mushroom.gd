extends Area2D


signal collected
var speed:float
const SPEED_RANGE = [100,100]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("mushrooms")
	speed = randf_range(SPEED_RANGE[0],SPEED_RANGE[1])
	body_entered.emit(_on_body_entered) # not working?


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > 230 and get_parent().current_game_state == get_parent().GAME_STATE.PLAYING:
		$Sprite2D.texture = load("res://games/mushroom/assets/mushroom-lose.png")
		speed = 0
		await get_tree().create_timer(.5).timeout
		get_parent().lose()


func _on_body_entered(body:PhysicsBody2D):
	print('area entered')
	collected.emit()
	queue_free()
