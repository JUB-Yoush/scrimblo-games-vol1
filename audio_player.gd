extends AudioStreamPlayer


var audio_bus_name := "Master"
var game_over = false
@onready var _bus := AudioServer.get_bus_index(audio_bus_name)
@onready var sfxPlayer = $SFXPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	set_volume(5)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_music(music:AudioStream):
	if game_over:
		return
	# if stream == music:
	# 	return

	stream = music
	play()
func pause_music():
	stop()


func play_sfx(sfx:AudioStream):
	sfxPlayer.stream = sfx
	sfxPlayer.play()

func set_volume(value):
	AudioServer.set_bus_volume_db(_bus,linear_to_db(value))
