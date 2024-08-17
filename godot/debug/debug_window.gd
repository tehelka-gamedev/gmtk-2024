extends MarginContainer

@onready var game_state_value:Label = $VBoxContainer/HBoxContainer/GSValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.game_state_changed.connect(_on_game_state_changed)
	
	_on_game_state_changed(GameState.current_game_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		visible = not visible

func _on_game_state_changed(new_game_state:Enum.GameState) -> void:
	game_state_value.text = Enum.GameState.keys()[new_game_state]
