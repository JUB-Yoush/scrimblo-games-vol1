extends Node2D
# game:
# countdown from 3, draw appears
# have to press the button after draw appears
# press to early/late, lose

signal game_over(result)

enum GAME_STATE {SETUP,DRAWING,DRAWN,ROUND_END,DONE}

var current_game_state = GAME_STATE.SETUP
var countdown_sprite := ""
var level = 0
var player_shot:bool
const DRAW_SPEEDS:Array[float] = [1,0.5,0.25]

const DRAW_VARIANCE:float = 5.0
var rng = RandomNumberGenerator.new()
@onready var countdown:Sprite2D = $Countdown

func _ready() -> void:
	play_round()
	pass # Replace with function body.

func lose():
	game_over.emit(false)
	print('you lose')
	pass

func shoot():
	player_shot = true
	print('you win')
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("draw"):
		if current_game_state == GAME_STATE.DRAWING:
			print('you lose')
			lose()
			pass
		elif current_game_state == GAME_STATE.DRAWN:
			shoot()

func play_round():
	current_game_state = GAME_STATE.DRAWING
	# render 3,2,1 then make draw appear, with some vairance
	countdown.texture = load("res://games/quickdraw/assets/temp-timer1.png")
	await get_tree().create_timer(1).timeout
	countdown.texture = load("res://games/quickdraw/assets/temp-timer2.png")
	await get_tree().create_timer(1).timeout
	countdown.texture = load("res://games/quickdraw/assets/temp-timer3.png")
	await get_tree().create_timer(1).timeout
	var extra_time = 2 + rng.randf_range(-DRAW_VARIANCE, DRAW_VARIANCE)
	await get_tree().create_timer(extra_time).timeout
	draw()

func draw():
	current_game_state = GAME_STATE.DRAWN
	print('draw')
	await get_tree().create_timer(DRAW_SPEEDS[level]).timeout
	current_game_state = GAME_STATE.ROUND_END
	if not player_shot:
		lose()


