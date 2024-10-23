extends CharacterBody2D

var speed = 100.0
var can_move = false
var dir = Vector2.ZERO
var can_hit = true
func _ready():
	$Hurtbox.area_entered.connect(on_area_entered)
	pass


func _process(delta: float) -> void:
	if !can_move:
		return
	dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = speed * dir
	move_and_slide()


func on_area_entered(area:Area2D):
	if area.is_in_group("bullets") and can_hit:
		get_parent().get_parent().take_damage(area.damage)
		hitflash()
		area.queue_free()

func hitflash():
	can_hit = false
	var flashspeed = 0.1
	for i in range(3):
		$Sprite.visible = false
		await get_tree().create_timer(flashspeed).timeout
		$Sprite.visible = true
		await get_tree().create_timer(flashspeed).timeout
	can_hit = true

