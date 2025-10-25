extends Node2D

@onready var enemy_parent = $Enemy_Parent
@onready var spawn_timer = $Timer
@onready var difficulty_timer = $DifficultyTimer
@onready var spawn_container = $SpawnContainer
@onready var enemy_container = $Enemy_Parent
@onready var camera = $Camera
@onready var stopwatch = $Stopwatch
@onready var difficulty_value = $CanvasLayer/VBoxContainer/Top/DifficultyLabel2
@onready var enemy_score = $CanvasLayer/VBoxContainer/Bottom/EnemyScore2
@onready var game_over_screen = $CanvasLayer/GameOver

@export var stopwatch_label: Label

var Enemy = preload("res://enemy.tscn")
var active_enemy: Node = null
var current_letter_index: int = -1
var difficulty: int = 0
var enemies_killed: int = 0

func _ready() -> void:
	game_over_screen.hide()
	randomize()
	spawn_timer.start()
	spawn_enemy()
	
func _process(delta: float) -> void:
	update_stopwatch_label()
	
func update_stopwatch_label() -> void:
	if stopwatch_label and stopwatch:
		stopwatch_label.text = stopwatch.time_to_string()
	
func find_new_active_enemy(typed_character: String) -> void:
	for enemy in enemy_parent.get_children():
		var prompt: String = enemy.get_prompt()
		var next_character: String = prompt.substr(0, 1)
		if next_character == typed_character:
			print("Found NEW Enemy, %s" % next_character)
			active_enemy = enemy
			current_letter_index = 1
			active_enemy.set_next_character(current_letter_index)
			return

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.unicode > 0:
			var key_typed := String.chr(event.unicode)
			print("Key typed: ", key_typed)

			if active_enemy == null:
				find_new_active_enemy(key_typed)
			else:
				var prompt: String = active_enemy.get_prompt()
				var next_character: String = prompt.substr(current_letter_index, 1)

				if key_typed == next_character:
					print("Successfully Typed %s" % key_typed)
					current_letter_index += 1
					active_enemy.set_next_character(current_letter_index)

					if current_letter_index == prompt.length():
						print("Word completed! Enemy explodes!")
						active_enemy.die()
						camera.screen_shake(30, 0.5)
						active_enemy.queue_free()
						active_enemy = null
						current_letter_index = -1
						enemies_killed += 1 
						enemy_score.text = str(enemies_killed)
				else:
					print("Incorrectly typed %s instead of %s" % [key_typed, next_character])

func _on_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	var enemy_instance = Enemy.instantiate()
	var spawns = spawn_container.get_children()
	if spawns.is_empty():
		push_error("No spawn points found in SpawnContainer!")
		return

	var index = randi() % spawns.size()
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)
	enemy_instance.global_position = spawns[index].global_position

func _on_difficulty_timer_timeout() -> void:
	difficulty += 1
	GlobalSignals.emit_signal("difficulty_increased", difficulty)
	print("Difficulty Increased to %d" % difficulty)
	
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1.0, spawn_timer.wait_time)
	difficulty_value.text = str(difficulty)


func _on_area_2d_body_entered(body: Node2D) -> void:
	game_over()

func game_over():
	stopwatch.stop()
	game_over_screen.show()
	spawn_timer.stop()
	difficulty_timer.stop()
	active_enemy = null
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()

	
func start_game():
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	current_letter_index = -1
	active_enemy = null
	stopwatch.reset()
	enemy_score.text = "0"
	difficulty_value.text = "0"
	randomize()
	spawn_timer.start()
	difficulty_timer.start()
	spawn_enemy()




func _on_restart_button_pressed() -> void:
	start_game()
