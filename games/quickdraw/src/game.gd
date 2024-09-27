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
@onready var scrimblo:Sprite2D = $Scrimblo
@onready var wizard:Sprite2D = $Wizard
func _ready() -> void:
	play_round()
	pass # Replace with function body.

func lose():
	var rigid := RigidBody2D.new()
	rigid.linear_velocity.x = -200
	add_child(rigid)
	scrimblo.hide()
	var newScrimblo = Sprite2D.new()
	newScrimblo.texture = load("res://games/quickdraw/assets/scrimblo-cowboy3.png")
	rigid.global_position = scrimblo.global_position
	rigid.add_child(newScrimblo)


	countdown.texture = null
	scrimblo.texture = load("res://games/quickdraw/assets/scrimblo-cowboy3.png")
	wizard.texture = load("res://games/quickdraw/assets/wizard-cowboy2.png")
	print('you lose')
	game_over.emit(0)
	pass

func shoot():
	player_shot = true

	var rigid := RigidBody2D.new()
	rigid.linear_velocity.x = 200
	add_child(rigid)
	wizard.hide()
	var newWizard = Sprite2D.new()
	newWizard.texture = load("res://games/quickdraw/assets/wizard-cowboy3.png")
	rigid.global_position = wizard.global_position
	rigid.add_child(newWizard)

	scrimblo.texture = load("res://games/quickdraw/assets/scrimblo-cowboy2.png")
	countdown.texture = null
	print('you win')
	game_over.emit(1)
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("draw"):
		if current_game_state == GAME_STATE.DRAWING:
			countdown.texture = null
			lose()
			current_game_state = GAME_STATE.ROUND_END
			pass
		elif current_game_state == GAME_STATE.DRAWN:
			shoot()
			current_game_state = GAME_STATE.ROUND_END

func play_round():
	current_game_state = GAME_STATE.SETUP
	# render 3,2,1 then make draw appear, with some vairance
	countdown.texture = load("res://games/quickdraw/assets/timer1.png")
	await get_tree().create_timer(1).timeout
	countdown.texture = load("res://games/quickdraw/assets/timer2.png")
	await get_tree().create_timer(1).timeout
	countdown.texture = load("res://games/quickdraw/assets/timer3.png")
	await get_tree().create_timer(1).timeout
	countdown.texture = null
	current_game_state = GAME_STATE.DRAWING
	var extra_time = 2 + rng.randf_range(-DRAW_VARIANCE, DRAW_VARIANCE)
	await get_tree().create_timer(extra_time).timeout
	draw()

func draw():
	countdown.texture = load("res://games/quickdraw/assets/timer4.png")
	wizard.texture = load("res://games/quickdraw/assets/wizard-cowboy2.png")
	current_game_state = GAME_STATE.DRAWN
	await get_tree().create_timer(DRAW_SPEEDS[level]).timeout
	current_game_state = GAME_STATE.ROUND_END
	if not player_shot:
		lose()


