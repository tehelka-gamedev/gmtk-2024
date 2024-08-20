class_name PauseMenu
extends ColorRect

@export var button_resume:Button = null
@export var button_restart_level:Button = null
@export var button_menu:Button = null

@export_file("*.tscn") var main_menu_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.pause_game.connect(_on_pause)
	Events.unpause_game.connect(_on_unpause)
	
	button_resume.pressed.connect(func():
		Events.unpause()
	)
	
	button_restart_level.pressed.connect(func():
		Events.unpause()
		get_tree().reload_current_scene()
	)
	
	button_menu.pressed.connect(func():
		Events.unpause()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file(main_menu_scene)
	)
	
	hide()
	


func _on_pause() -> void:
	show()

func _on_unpause() -> void:
	hide()
