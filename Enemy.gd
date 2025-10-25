extends CharacterBody2D

@export var deathParticle: PackedScene
@export var red: Color = Color.RED
@export var speed: float = 0.5

@onready var prompt: RichTextLabel = $RichTextLabel

var is_locked_on: bool = false
var raw_prompt: String = ""  # store clean text here

func _ready() -> void:
	raw_prompt = PromptList.get_prompt()
	prompt.parse_bbcode(set_center_tags(raw_prompt))
	GlobalSignals.difficulty_increased.connect(handle_difficulty_increased)
	
func set_difficulty(difficulty: int):
	handle_difficulty_increased(difficulty)


func handle_difficulty_increased(new_difficulty: int):
	var new_speed = speed + (0.1 * new_difficulty)
	speed = clamp(new_speed, speed, 2)
	

func _physics_process(delta: float) -> void:
	global_position.y += speed

func get_prompt() -> String:
	return raw_prompt

func set_next_character(next_character_index: int) -> void:
	var original_text = get_prompt()

	if next_character_index <= 0 or next_character_index > raw_prompt.length():
		return  # avoid out-of-range errors

	var highlighted = original_text.substr(0, next_character_index)
	var remaining = original_text.substr(next_character_index)
	var red_text = get_bbcode_color_tag(red) + highlighted + get_bbcode_end_color_tag() + remaining

	prompt.parse_bbcode(set_center_tags(red_text))

func set_center_tags(string_to_center: String) -> String:
	return "[center]" + string_to_center + "[/center]"

func die() -> void:
	var particle = deathParticle.instantiate()
	particle.global_position = global_position
	particle.global_rotation = global_rotation
	particle.emitting = true

	get_tree().current_scene.add_child(particle)
	queue_free()

func get_bbcode_color_tag(color: Color) -> String:
	return "[color=" + color.to_html(false) + "]"

func get_bbcode_end_color_tag() -> String:
	return "[/color]"
