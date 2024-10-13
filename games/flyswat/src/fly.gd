extends CharacterBody2D
class_name Fly

# make flight patterns
# dtc style spawning (https://docs.godotengine.org/en/stable/getting_started/first_2d_game/05.the_main_game_scene.html#spawning-mobs)
signal died
var speed:int
var arc:float
var dir:Vector2
var alive:bool = true
const SPEED_RANGE :Array[float]= [100.0,500.0]

@onready var onScreen:VisibleOnScreenNotifier2D = $OnScreen
func _ready() -> void:
	$OnScreen.screen_exited.connect(func(): queue_free())
	$Area2D.input_event.connect(on_clicked)

func _process(delta) -> void:
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
			alive = false
			died.emit()
			print('died')
		# change sprites or something






