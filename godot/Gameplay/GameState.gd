extends Node

signal game_state_changed(new_state: Enum.GAME_STATE)

var current_game_state: Enum.GAME_STATE = Enum.GAME_STATE.FREE_CAMERA : 
	set(value):
		current_game_state = value
		game_state_changed.emit(value)
	get:
		return current_game_state
