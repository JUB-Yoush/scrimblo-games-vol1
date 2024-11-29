extends Node2D

@onready var player := $Player
@onready var playerSprite :=$Player/Sprite2D
@onready var playerHbox := $Player/Hitbox

const PROMPT = "MUSHROOM"

var mushroomScene:PackedScene = load("res://games/mushroom/src/mushroom.tscn")
var collected_count = 0
var required = 10
var player_speed := 125.0
var spawn_range = 250
var eating = false
enum GAME_STATE {SETUP,PLAYING,DONE}

var current_game_state = GAME_STATE.SETUP
var dir:Vector2
var shroomTimer:Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Macaroni.flip_h = true
	playerSprite.flip_h = true
	add_child(shroomTimer)
	shroomTimer.timeout.connect(
		func():
		var newShroom = mushroomScene.instantiate()
		newShroom.position.x = randf_range(65,spawn_range)
		newShroom.position.y = 0
		newShroom.collected.connect(func(): collected_count+=1)
		add_child(newShroom)
		shroomTimer.start(1)
		)
	shroomTimer.one_shot = true
	playerHbox.area_entered.connect(on_area_entered)
	eating = true
	playerSprite.frame = 2
	%AnimationPlayer.play("start")
	await %AnimationPlayer.animation_finished
	eating = false
	shroomTimer.start(1.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	dir = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),0)
	player.velocity = dir * player_speed
	if not eating:
		%AnimationPlayer.play("walk")
		player.move_and_slide()
	pass

func on_area_entered(area):
	area.queue_free()
	eating = true
	%AnimationPlayer.play("eat")
	await %AnimationPlayer.animation_finished
	eating = false