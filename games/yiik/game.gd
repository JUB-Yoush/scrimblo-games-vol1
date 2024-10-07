extends Node2D

#https://youtu.be/qRPI_c9qI1o?si=GQsg6SjXqMKiYQpa
# Called when the node enters the scene tree for the first time.


@export var blue := Color("#4682b4")
@export var green := Color("#639765")
@export var red := Color("#a65455")

var current_char_index:int = 1
var sentence:String

var PROMPTS = [
	"I had known her for less than two hours when she vanished from my sight.",
	"Sammy was gone for good, swept away as if she'd never been there at all.",
	"A door into nothing, into a different reality, opened up and swalloed Sammy whole.",
	"At that moment I couldn't think, I couldn't breathe.",
	"All I could do was replay the scene of her being pulled into obscurity by nothing",
	"There one second and gone the next",
]
var prompt_index = 0
@onready var richTextLabel:RichTextLabel = $Panel/RichTextLabel
signal game_over(result)
func _ready() -> void:
	richTextLabel.text = PROMPTS[0]
	sentence = richTextLabel.text
	current_char_index = 0
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var typed_event = event as InputEventKey
		var key_typed = PackedByteArray([typed_event.unicode]).get_string_from_utf8()
		var next_char = sentence.substr(current_char_index,1)
		print(next_char)
		print("next char is "+next_char)
		if key_typed == next_char:
			print("typed "+ key_typed)
			current_char_index+=1
			set_next_char(current_char_index)
			if current_char_index == sentence.length():
				change_prompt()
				game_over.emit(1)
		else:
			print("wrong char of instead of" ,  key_typed, next_char)
		next_char = sentence.substr(current_char_index,1)
		print("next char is",next_char)

func set_next_char(next_char_index:int) -> void:
	var blue_text = get_bbcode_color_tag(blue) + sentence.substr(0,next_char_index) + get_bbcode_end_color_tag()
	var green_text = get_bbcode_color_tag(green) + sentence.substr(next_char_index,1) + get_bbcode_end_color_tag()
	var red_text = ""
	if next_char_index != sentence.length():
		red_text = get_bbcode_color_tag(red) + sentence.substr(next_char_index+1, sentence.length() - next_char_index +1) + get_bbcode_end_color_tag()
	richTextLabel.parse_bbcode(blue_text + green_text + red_text)


func get_bbcode_color_tag(color:Color) -> String:
	return "[color=#" + color.to_html(false) + "]"

func get_bbcode_end_color_tag() -> String:
	return "[/color]"

func change_prompt():
	prompt_index += 1
	richTextLabel.text = PROMPTS[prompt_index]
	sentence = richTextLabel.text
	current_char_index = 0
	set_next_char(current_char_index)