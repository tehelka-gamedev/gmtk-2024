extends Node3D


var current_selected_object:GameObject = null
@export var target_height: float = 5.0

@onready var _height_detector: HeightDetector = $HeightDetector
@onready var _billboard: Billboard = $Billboard
@onready var _player_camera: PlayerCamera = $PlayerCamera
@onready var _hud: HUD = $HUD


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_height_detector.max_height_changed.connect(_on_max_height_changed)
	_billboard.set_target_height(target_height)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	# Handle focus/unfocus with escape / click on the viewport
	if event.is_action_pressed("ui_cancel"):
		if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif GameState.current_game_state == Enum.GameState.OBJECT_SELECTED:
			_unselect_current_object()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("select_object"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
		elif GameState.current_game_state == Enum.GameState.FREE_CAMERA:
			var object: GameObject = _player_camera.get_object_under_mouse(event.position)
			if object :
				select(object)
				get_viewport().set_input_as_handled()
		elif current_selected_object != null and current_selected_object.is_not_colliding():
			_unselect_current_object()
			get_viewport().set_input_as_handled()
	elif (
		event.is_action_pressed("allow_object_rotation")
		and GameState.current_game_state == Enum.GameState.OBJECT_SELECTED
	):
		GameState.current_game_state = Enum.GameState.ROTATING_OBJECT
	elif (
		event.is_action_released("allow_object_rotation")
		and GameState.current_game_state == Enum.GameState.ROTATING_OBJECT
	):
		GameState.current_game_state = Enum.GameState.OBJECT_SELECTED


func _unselect_current_object() -> void:
	assert (current_selected_object!=null, "Trying to unselect an object but none is selected, something is wrong!")
	
	current_selected_object.selected = false
	GameState.current_game_state = Enum.GameState.FREE_CAMERA
	current_selected_object = null
	_player_camera.detach_object()


func _on_max_height_changed(max_height: float) -> void:
	_billboard.set_max_height(max_height)
	if max_height >= target_height:
		_hud.show_win()


func select(object: GameObject) -> void:
	if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
		GameState.current_game_state = Enum.GameState.OBJECT_SELECTED
		object.selected = true
		current_selected_object = object
		
		_player_camera.attach_object(object.global_position, _player_camera.get_path_to(object))
