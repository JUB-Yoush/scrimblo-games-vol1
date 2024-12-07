extends Node2D

#var microgames:Array[String] = ["quickdraw","yiik","flyswat","yudumsort",]
var microgames:Array[String] = ["yudumsort"]
var playedGames:Array[String] = []
var result:bool

var lives:int = 3:
	set(value):
		%Lifebar.visible = true
		var lifeSprite = get_node("Lifebar/Lives%d" % lives)
		await get_tree().create_timer(.5).timeout
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
@onready var minigameWindow = $SubViewportContainer/Minigame
@onready var gameParent = $GameParent
@onready var animPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	move_scrimblo()
	between_games(true,null,null)
	%WinSprite.visible = false
	pass # Replace with function body.

func game_over():
	print('the WHOLE THING is over you SUCK')
	pass

func boss_state():
	pass

func select_game():
	if playedGames.size() == microgames.size():
		boss_state()
	var gameString:String = microgames.pick_random()

	while playedGames.has(gameString):
		gameString = microgames.pick_random()

	gameString = "res://games/%s/src/game.tscn" % gameString
	return gameString


func play_game(gameInstance,gameString):
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
			await animPlayer.animation_finished
		game_string = select_game()
		nextGame = load(game_string).instantiate()
	else:
		game_string = prevGameString
		nextGame = load(prevGameString).instantiate()

	animPlayer.play("close")
	await animPlayer.animation_finished
	if result == false:
		lives -= 1
		await get_tree().create_timer(.5).timeout

	%ProgressUi.visible = true
	if runningGame != null:
		runningGame.queue_free()
	if result == true and prevGame != null:
		move_scrimblo()

	%PromptText.text = nextGame.PROMPT
	%Prompt.visible = true
	await get_tree().create_timer(1).timeout
	%ProgressUi.visible = false
	animPlayer.play("open")
	%Prompt.visible = false
	play_game(nextGame,game_string)
