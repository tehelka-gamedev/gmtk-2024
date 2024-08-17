extends Node3D


var current_selected_object:GameObject = null

@onready var _height_detector: HeightDetector = $HeightDetector
@onready var _billboard: Billboard = $Billboard
@onready var player_camera:PlayerCamera = $PlayerCamera


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_height_detector.max_height_changed.connect(_on_max_height_changed)
	
	player_camera.object_clicked.connect(_on_object_clicked)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if current_selected_object != null:
				_unselect_current_object()
				print("nope")

func _unselect_current_object() -> void:
	assert (current_selected_object!=null, "Trying to unselect an object but none is selected, something is wrong!")
	
	current_selected_object.selected = false
	GameState.current_game_state = Enum.GameState.FREE_CAMERA
	current_selected_object = null

func _on_max_height_changed(max_height: float) -> void:
	_billboard.change_max_height(max_height)

func _on_object_clicked(object:GameObject) -> void:
	if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
		print("yes")
		GameState.current_game_state = Enum.GameState.OBJECT_SELECTED
		object.selected = true
		current_selected_object = object
		get_viewport().set_input_as_handled()
