extends Node2D

# Called when the node enters the scene tree for the first time.


@export var blue := Color("#38495e")
@export var green := Color("#639765")
@export var red := Color("#4682b4")

var deathTimer = Timer.new()

const PROMPT = "TYPE"
const CONTROLS = "keeb"
var current_char_index:int = 1
var sentence:String

# calculate
var wpm = 50.0
var seconds = 0.0
var typed_chars = 10.0
var typing_started = false

var PROMPTS = [
	"I had known her for less than two hours when she vanished from my sight.",
	"Sammy was gone for good, swept away as if she'd never been there at all.",
	"A door into nothing, into a different reality, opened up and swalloed Sammy whole.",
	"At that moment I couldn't think, I couldn't breathe.",
	"All I could do was replay the scene of her being pulled into obscurity by nothing.",
	"There one second and gone the next.",
]
var prompt_index = 0
@onready var richTextLabel:RichTextLabel = $Panel/RichTextLabel
signal game_over(result)
func _ready() -> void:
	AudioPlayer.play_music(preload("res://assets/sound/music/output.ogg"))
	%MarginContainer.rotation = 0
	var clock = Timer.new()
	clock.timeout.connect(
	func():
		seconds+=.1
		update_wpm()
	)
	clock.one_shot = false
	add_child(clock)
	clock.start(.1)
	deathTimer.paused = true
	add_child(deathTimer)
	deathTimer.timeout.connect( func():
		game_over.emit(0)
	)
	richTextLabel.visible = false

	$AnimationPlayer.play('slide_in')
	await $AnimationPlayer.animation_finished
	richTextLabel.visible = true
	richTextLabel.text = PROMPTS[0]
	sentence = richTextLabel.text
	current_char_index = 0
	set_next_char(0)
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
			typed_chars += 1
			update_wpm()
			current_char_index+=1
			set_next_char(current_char_index)
			if current_char_index == sentence.length():
				change_prompt()
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
	if prompt_index == PROMPTS.size():
		game_over.emit(1)
		return
	richTextLabel.text = PROMPTS[prompt_index]
	sentence = richTextLabel.text
	current_char_index = 0
	set_next_char(current_char_index)

func update_wpm():
	wpm = (typed_chars/5) / (seconds/60)
	%WPMLabel.text = "WPM: " + str(roundf(wpm))
	%WPMBar.value = wpm
	if !typing_started:
		return
	if wpm < 60:
		%WPMBar.texture_progress = load("res://games/yiik/assets/bar-inner-bad.png")
		%WPMLabel.modulate = Color.RED
		if deathTimer.paused:
			deathTimer.paused = false
			%AnimationPlayer.play('shake')
			deathTimer.start(3)
	if wpm >= 60:
		%WPMBar.texture_progress = load("res://games/yiik/assets/bar-inner.png")
		%WPMLabel.modulate = Color.WHITE
		deathTimer.paused = true
		%AnimationPlayer.pause()
		%MarginContainer.rotation = 0
func start_typing():
	typing_started = true
