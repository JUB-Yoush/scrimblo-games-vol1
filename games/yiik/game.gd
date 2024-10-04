extends Node2D

#https://youtu.be/qRPI_c9qI1o?si=GQsg6SjXqMKiYQpa
# Called when the node enters the scene tree for the first time.

var current_char_index:int = 1
@onready var richTextLabel:RichTextLabel = $Panel/RichTextLabel
signal game_over(result)
func _ready() -> void:
	current_char_index = 1
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var typed_event = event as InputEventKey
		var key_typed = PackedByteArray([typed_event.unicode]).get_string_from_utf8()
		var next_char = richTextLabel.substr(current_char_index,1)
		print("next char is %s",next_char)
		if key_typed == next_char:
			print("typed %s" % key_typed)
			current_char_index+=1
			if current_char_index == richTextLabel.length():
				game_over.emit(1)
		else:
			print("wrong char of %s instead of %s" % key_typed, next_char)
		next_char = richTextLabel.substr(current_char_index,1)
		print("next char is %s",next_char)
