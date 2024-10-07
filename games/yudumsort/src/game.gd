extends Node2D

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
    "Ridge Racer Type R4 + Pepsi Man",
    "Touhou Artificial Dream in Arcadia (Demo)",
    "Hotline Miami",
    "The Murder of Sonic the Hedgehog",
    "Sleeping Dogs: Definitive Edition",
    "Disco Elysium",
    "Super Mario 64",
]
var pool = range(GAMES.size())
var correct_btn_index :int
var right = 0
var wrong = 0
var choice_made = false
signal game_over(result)
func _ready() -> void:
    pick_games()
    $Button1.pressed.connect(func(): picked(1))
    $Button2.pressed.connect(func(): picked(2))



func pick_games():
    pool.shuffle()
    var game1 = GAMES[pool.pop_front()]
    var game2 = GAMES[pool.pop_front()]

    if GAMES.find(game1) > GAMES.find(game2):
        correct_btn_index = 2
    else:
        correct_btn_index = 1
    $Button1.text = game1
    $Button2.text = game2

func picked(choice:int) -> void:
    if choice_made:
        return
    if choice == correct_btn_index:
        print('right choice')
        #win things
        right += 1
        if right == 5:
            game_over.emit(1)
        pass
    else:
        print('wrong choice')
        wrong += 1
        if wrong == 3:
            game_over.emit(0)
        #lose things
        pass
    pick_games()
