extends Node2D

@onready var player := $Player
@onready var playerSprite :=$Player/Sprite2D
@onready var playerHbox := $Player/Hitbox

const PROMPT = "MUSHROOM"

const CONTROLS = "wasd"

signal game_over(result)

var mushroomScene:PackedScene = load("res://games/mushroom/src/mushroom.tscn")

var required = 10
var collected_count = 0:
	set(value):
		collected_count = value
		print(collected_count)
		if collected_count == required:
			current_game_state = GAME_STATE.DONE
			%AnimationPlayer.play('win')
			await %AnimationPlayer.animation_finished
			game_over.emit(1)

var player_speed := 125.0
var spawn_range = 300
var eating = false
enum GAME_STATE {SETUP,PLAYING,DONE}

var current_game_state = GAME_STATE.SETUP
var dir:Vector2
var shroomTimer:Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music(preload("res://assets/sound/music/mario64.ogg"))
	%Macaroni.flip_h = true
	playerSprite.flip_h = true
	add_child(shroomTimer)
	shroomTimer.timeout.connect(
		func():
		if current_game_state == GAME_STATE.PLAYING:
			var newShroom = mushroomScene.instantiate()
			newShroom.position.x = randf_range(100,spawn_range)
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
	current_game_state = GAME_STATE.PLAYING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if current_game_state == GAME_STATE.PLAYING:
		dir = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),0)
		player.velocity = dir * player_speed
		if not eating:
			%AnimationPlayer.play("walk")
			player.move_and_slide()
		pass

func on_area_entered(area):
	if current_game_state == GAME_STATE.PLAYING:
		area.queue_free()
		eating = true
		AudioPlayer.play_sfx(preload("res://assets/sound/sfx/eat.wav"))
		%AnimationPlayer.play("eat")
		await %AnimationPlayer.animation_finished
		collected_count += 1
		eating = false

func lose():
	if current_game_state == GAME_STATE.PLAYING:
		game_over.emit(0)

