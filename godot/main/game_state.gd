extends Node

signal game_state_changed(new_state: Enum.GameState)

var current_game_state: Enum.GameState = Enum.GameState.FREE_CAMERA : 
	set(value):
		current_game_state = value
		game_state_changed.emit(value)
	get:
		return current_game_state


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_game_state == Enum.GameState.OBJECT_SELECTED:
			current_game_state = Enum.GameState.FREE_CAMERA
