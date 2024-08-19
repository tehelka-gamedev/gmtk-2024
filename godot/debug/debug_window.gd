extends MarginContainer

@onready var game_state_value:Label = $VBoxContainer/HBoxContainer/GSValue
@onready var mouse_pos_value:Label = $VBoxContainer/HBoxContainer2/MPValue

func _ready() -> void:
	GameState.game_state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(GameState.current_game_state)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		visible = not visible
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos_value.text =  str(event.position) + " / " + str(get_viewport().get_mouse_position()) + (
			" / " + str(event.relative)
		)


func _on_game_state_changed(new_game_state:Enum.GameState) -> void:
	game_state_value.text = Enum.GameState.keys()[new_game_state]
