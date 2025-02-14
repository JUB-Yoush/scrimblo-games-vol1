extends Area2D

var speed_variance := 50.0
var speed := 80.0
var velocity = Vector2.DOWN
var timeout_variance = 1
var time = 2
var difficulty
var bullet_angle = 30.0 # in degrees
@onready var timer := Timer.new()
var bulletScene :PackedScene= load('res://games/vsKayla/bullet.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer)
	speed += randf_range(-speed_variance,speed_variance)
	timer.timeout.connect(spawn_bullets)
	timer.start(randf_range(.8,1.8))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta
	pass

func spawn_bullets():
	# spawn 3 in a spread
	var player = get_parent().get_node("Heart")
	var vector_to_player :Vector2 = player.global_position - global_position

	var bullet = bulletScene.instantiate()
	var bullet2 = bulletScene.instantiate()
	var bullet3 = bulletScene.instantiate()

	bullet.global_position = global_position
	bullet2.global_position = global_position
	bullet3.global_position = global_position

	bullet.dir = vector_to_player.normalized()
	bullet2.dir = vector_to_player.normalized().rotated(deg_to_rad(20))
	bullet3.dir = vector_to_player.normalized().rotated(deg_to_rad(-20))

	bullet.damage = 2
	bullet2.damage = 2
	bullet3.damage = 2

	bullet.speed = 150
	bullet2.speed = 120
	bullet3.speed = 120
	#give it sprite and area?
	get_parent().add_child(bullet)
	get_parent().add_child(bullet2)
	get_parent().add_child(bullet3)
	queue_free()
