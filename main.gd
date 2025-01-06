extends Node2D

#var microgames:Array[String] = ["res://games/quickdraw/src/game.tscn",
#"res://games/yiik/src/game.tscn",
#"res://games/flyswat/src/game.tscn",
#"res://games/yudumsort/src/game.tscn",
#"res://games/mushroom/src/game.tscn",]
var microgames:Array[String] = [
"res://games/flyswat/src/game.tscn",
]
var playedGames:Array[String] = []
var result:bool
var currentGame
var at_boss = false

var lives:int = 3:
	set(value):
		%Lifebar.visible = true
		var lifeSprite = get_node("Lifebar/Lives%d" % lives)
		await get_tree().create_timer(.5).timeout
		AudioPlayer.play_sfx(preload("res://assets/sound/sfx/explosion.wav"))
		lifeSprite.texture = load("res://assets/explosion/gamemaker_explosion.png")
		lifeSprite.hframes = 17
		lifeSprite.frame = 0
		while lifeSprite.frame < 15:
			await get_tree().create_timer(.04).timeout
			lifeSprite.frame +=1
		lifeSprite.visible = false
		await get_tree().create_timer(.3).timeout
		%Lifebar.visible = false
		lives = value
		if lives == 0:
			game_over()

var score:int
@onready var gameParent = $GameParent
@onready var animPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	microgames.shuffle()
	score = 0
	move_scrimblo()
	between_games(true,null,null)
	%WinSprite.visible = false
	%RetryButton.pressed.connect(restart)
	pass # Replace with function body.

func game_over():
	get_tree().paused = true
	%LoseAnimPlayer.play("wipe")
	await get_tree().create_timer(1).timeout
	%LosePanel.visible = true


func restart():
	print("pressing")
	print("before pause: ",get_tree())
	get_tree().paused = false
	print("after pause: ",get_tree())
	%LosePanel.visible = false
	#await get_tree().create_timer(1).timeout
	#get_tree().change_scene_to_file('res://main.tscn')
	get_tree().reload_current_scene()

func boss_state():
	%PromptText.text = "BOSS STAGE"
	var gameInstance = load("res://games/vsKayla/game.tscn").instantiate()
	play_game(gameInstance,"res://games/vsKayla/game.tscn")

func select_game():
	var gameString:String

	if microgames.size() == 0:
		gameString = "res://games/vsKayla/game.tscn"
		return gameString
	else:
		gameString = microgames.pop_front()
		return gameString


func play_game(gameInstance,gameString):
	currentGame = gameInstance
	gameParent.add_child(gameInstance)
	gameInstance.game_over.connect(func(res): result = res )
	await gameInstance.game_over
	print('game is over now bye')
	if result == true:
		playedGames.append(gameString)
		score += 2
	else:
		playedGames.append(gameString)
		score -= 1
		lives -= 1
	if lives > 0:
		between_games(result,gameInstance,gameString)

func move_scrimblo():
	var scrimblo_move_offset = 64
	var tween = create_tween()
	tween.tween_property(%ScrimbloIcon,"position",Vector2(%ScrimbloIcon.position.x + 64,%ScrimbloIcon.position.y),.5)

func between_games(result,prevGame,prevGameString):

	var game_string
	var nextGame
	var runningGame = prevGame
	if result == true:
		if prevGame != null:
			animPlayer.play("win")
			AudioPlayer.play_sfx(preload("res://assets/sound/sfx/golf-clap.wav"))
			await animPlayer.animation_finished

		if prevGameString == "res://games/vsKayla/game.tscn":
			get_tree().change_scene_to_file("res://win.tscn")
		game_string = select_game()
		nextGame = load(game_string).instantiate()
	else:
		game_string = prevGameString
		nextGame = load(prevGameString).instantiate()

	animPlayer.play("close")
	await animPlayer.animation_finished
	AudioPlayer.stop()
	if result == false:
		lives -= 1
		await get_tree().create_timer(.5).timeout

	%ProgressUi.visible = true
	if runningGame != null:
		runningGame.queue_free()
	if result == true and prevGame != null:
		move_scrimblo()

	%PromptText.text = nextGame.PROMPT
	if %PromptText.text == "BOSS":
		%Border.texture = null
	else:
		%Border.texture = load("res://assets/border.png")
	%PromptText.pivot_offset = %PromptText.size/2
	%PromptText.position.x = (432/2) - %PromptText.size.x/2
	%ControlImg.texture = load("res://assets/%s.png" % nextGame.CONTROLS)
	%PromptText.visible = true
	%Controls.visible = true

	await get_tree().create_timer(1.5).timeout
	%ProgressUi.visible = false
	%Controls.visible = false
	animPlayer.play("open")
	%PromptText.visible = false
	play_game(nextGame,game_string)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_LOSE"):
		currentGame.game_over.emit(0)
	elif event.is_action_pressed("DEBUG_WIN"):
		currentGame.game_over.emit(1)
