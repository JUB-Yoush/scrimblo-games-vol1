extends Node2D

# put one of these on there https://godotshaders.com/shader/earthbound-like-battle-background-shader-w-scroll-effect-and-palette-cycling/

const GAMES = [
	"Cave Story",
	"DOOM",
	"Portal",
	"Bloodborne PSX Demake",
	"Megamari",
	"PaRappa the Rapper",
	"Yume Nikki",
	"Patapon",
	"Metal Gear Solid",
	"Oneshot",
	"Ridge Racer Type R4",
	"Touhou Artificial Dream in Arcadia",
	"Hotline Miami",
	"The Murder of Sonic the Hedgehog",
	"Sleeping Dogs: Definitive Edition",
	"Disco Elysium",
	"Super Mario 64",
    "Silent Hill 2",
]
var pool = range(GAMES.size())
var round = 0
var correct_btn_index :int
var right = 0
var wrong = 0
var choice_made = false
signal game_over(result)
func _ready() -> void:
	pick_games()
	%Button1.pressed.connect(func(): picked(1))
	%Button2.pressed.connect(func(): picked(2))



func pick_games():
	pool.shuffle()
	var game1 = GAMES[pool.pop_front()]
	var game2 = GAMES[pool.pop_front()]

	if GAMES.find(game1) > GAMES.find(game2):
		correct_btn_index = 2
	else:
		correct_btn_index = 1
	%Button1.text = game1
	%Button2.text = game2

func picked(choice:int) -> void:
	if choice_made:
		return
	if choice == correct_btn_index:
		print('right choice')
		#win things
		right += 1
		%Score.get_child(round).texture = load("res://games/yudumsort/assets/o1.png")
		round += 1
		if right == 5:
			game_over.emit(1)
		pass
	else:
		print('wrong choice')
		%Score.get_child(round).texture = load("res://games/yudumsort/assets/o2.png")
		wrong += 1
		round += 1
		#if wrong == 3:
		game_over.emit(0)
		#lose things
		pass
	pick_games()
