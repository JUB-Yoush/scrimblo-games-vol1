extends Node2D

var microgames:Array[String] = ["quickdraw","yiik","flyswat","mushroom","yudumsort",]
var playedGames:Array[String] = []
var result:bool
var lives:int:
	set(value):
		lives = value
		if lives == 0:
			game_over()

var score:int
@onready var minigameWindow = $SubViewportContainer/Minigame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lives = 5
	score = 0
	pick_game()
	pass # Replace with function body.

func game_over():
	print('the WHOLE THING is over you SUCK')
	pass

func boss_state():
	pass

func pick_game():
	if playedGames.size() == microgames.size():
		boss_state()
	var gameString:String = microgames.pick_random()

	while playedGames.has(gameString):
		gameString = microgames.pick_random()

	gameString = "res://games/%s/src/game.tscn" % gameString
	var currGame:PackedScene = load(gameString)
	var gameInstance = currGame.instantiate()

	minigameWindow.add_child(gameInstance)
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
		pick_game()
