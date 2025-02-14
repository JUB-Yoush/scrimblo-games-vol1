extends CharacterBody2D
class_name Fly

# make flight patterns
# dtc style spawning (https://docs.godotengine.org/en/stable/getting_started/first_2d_game/05.the_main_game_scene.html#spawning-mobs)
signal died
var speed:int
var arc:float
var dir:Vector2
var alive:bool = true
const SPEED_RANGE :Array[float]= [100.0,200.0]

@onready var onScreen:VisibleOnScreenNotifier2D = $OnScreen
func _ready() -> void:
	$OnScreen.screen_exited.connect(func(): queue_free())
	$Area2D.input_event.connect(on_clicked)
	$AnimationPlayer.play("flap")

func _process(delta) -> void:
	$Area2D/CollisionShape2D.global_rotation = 0
	$Sprite2D.global_rotation = 0
	if alive:
		rotation += arc * delta
		velocity = velocity.rotated(arc)
	else:
		velocity = Vector2(0,200)
		rotation += arc * delta
		velocity = velocity.rotated(arc)
	move_and_slide()

func on_clicked(viewport,event,shape_idx):
	if event is InputEventMouseButton:
		if alive:
			AudioPlayer.play_sfx(preload("res://assets/sound/sfx/swat.wav"))
			alive = false
			died.emit()
			$Sprite2D.texture = load("res://games/flyswat/assets/fly-ded.png")
			$AnimationPlayer.stop()
			print('died')
		# change sprites or something






