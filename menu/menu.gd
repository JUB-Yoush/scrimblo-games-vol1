extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%StartButton.pressed.connect(func(): get_tree().change_scene_to_file('res://main.tscn'))
	%SettingsButton.pressed.connect(func(): get_tree().change_scene_to_file('res://menu/settings.tscn'))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
