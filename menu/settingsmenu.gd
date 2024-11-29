extends Control


# Called when the node enters the scene tree for the first time.
const WINDOW_MODE_ARRAY =[[432,240],[864,480]]
func _ready() -> void:
	%GameResToggle.item_selected.connect(resolution_toggled)
	%GameResToggle.add_item("x1 240")
	%GameResToggle.add_item("x2 480")
	%GameResToggle.add_item("x3 720")
	%GameResToggle.add_item("x4 960")
	%GameResToggle.add_item("x5 1200")
	%GameResToggle.add_item("x6 1440")

	%WindowStyleToggle.add_item("Fullscreen")
	%WindowStyleToggle.add_item("Borderless")
	%WindowStyleToggle.add_item("Window")

func resolution_toggled(index):
	DisplayServer.window_set_size(Vector2i(WINDOW_MODE_ARRAY[index][0],WINDOW_MODE_ARRAY[index][1]))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
