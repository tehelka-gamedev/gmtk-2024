extends Node

signal replay_requested
signal pause_game
signal unpause_game

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # just in case O:)

func pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	pause_game.emit()

func unpause() -> void:
	get_tree().paused = false
	unpause_game.emit()
