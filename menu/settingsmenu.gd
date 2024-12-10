extends Control

var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

#const WINDOW_MODE_ARRAY =[[432,240],[864,480]]
const BASE_RESOLUTION = Vector2i(432,240)
const WINDOW_MODE_ARRAY : Array[String] = [
	"Full-Screen",
	"Window Mode",
	"Borderless Window",
	"Borderless Full-Screen"
]

const RESOLUTIONS = {
	"x1 240p": BASE_RESOLUTION*1,
	"x2 480p": BASE_RESOLUTION*2,
	"x3 720p": BASE_RESOLUTION*3,
	"x4 960p": BASE_RESOLUTION*4,
	"x5 1200p": BASE_RESOLUTION*5,
	"x6 1440p": BASE_RESOLUTION*6,
}

func _ready() -> void:
	%VolumeSlider.value_changed.connect(func(value):AudioServer.set_bus_volume_db(_bus,linear_to_db(value)))


	%VsyncBox.toggled.connect(
	func(state):
		if state == true:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		if state == false:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		)
	%FramerateBox.toggled.connect(
	func(state):
		if state == true:
			Engine.max_fps = 60
		if state == false:
			Engine.max_fps = 0
		)
	%GameResToggle.item_selected.connect(resolution_toggled)
	for resolution in RESOLUTIONS:
		%GameResToggle.add_item(resolution)

	%WindowStyleToggle.item_selected.connect(on_window_mode_selected)
	for mode in WINDOW_MODE_ARRAY:
		%WindowStyleToggle.add_item(mode)

func on_window_mode_selected(index: int):
	match index:
	#"Full-Screen",
	#"Window Mode",
	#"Borderless Window",
	#"Borderless Full-Screen"
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)

func resolution_toggled(index):
	DisplayServer.window_set_size(RESOLUTIONS.values()[index])
	pass

