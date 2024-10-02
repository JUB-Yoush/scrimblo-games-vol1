extends CharacterBody2D

# make flight patterns
# dtc style spawning (https://docs.godotengine.org/en/stable/getting_started/first_2d_game/05.the_main_game_scene.html#spawning-mobs)

var speed:int
var arc:float
var dir:Vector2

@onready var onScreen:VisibleOnScreenNotifier2D = $OnScreen
func _ready() -> void:
	pick_arc()


func _process(delta) -> void:
	velocity += speed * dir
	move_and_slide()

func pick_arc(): # determine speed and curve
	arc = randf_range(0.001,0.1)


