extends Node3D


@export var target_height: float = 5.0
@export var object_pool:Array[PackedScene] = []
@export var select_max_distance: float = 5.0
@export var no_movement_duration_before_game_win: float = 3.0
@export var level_name: String
@export var sandbox_mode: bool = true
@export_file("*.tscn") var main_menu_scene: String

var _current_height: float = 0.0
var _last_time_something_has_moved: float = 0.0
var _current_selected_object: GameObject = null
var _current_hovered_object: GameObject = null
var _last_frame_object_position: Dictionary = {}

## True if the player has won, false otherwise
var _has_won:bool = false

@onready var _height_detector: HeightDetector = $HeightDetector
@onready var _billboard: Billboard = $Billboard
@onready var _player_camera: PlayerCamera = $PlayerCamera
@onready var _hud: HUD = $HUD

@onready var _objects = $Objects
@onready var _spawn_borders = $SpawnBorders
@onready var _scaling_gauge:Gauge = $ScalingGauge

## Picture taken at the end when winning
@export var _win_viewport:WinViewport = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	seed(randi())
	
	@warning_ignore("return_value_discarded")
	_height_detector.max_height_changed.connect(_on_max_height_changed)
	if sandbox_mode:
		_billboard.set_target_height(GameSettings.target_height)
		start_game()
	else:
		_billboard.set_target_height(target_height)
	
	for object: GameObject in _objects.get_children():
		_last_frame_object_position[object] = object.global_position


func _physics_process(delta: float) -> void:
	if not _has_won and _current_height >= target_height:
		if _no_object_has_moved_last_frame():
			_last_time_something_has_moved += delta
		
		if _last_time_something_has_moved >= no_movement_duration_before_game_win:
			win()

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if _current_selected_object == null:
		var mouse_position: Vector2 = get_viewport().get_mouse_position()
		var object: GameObject = _player_camera.get_object_under_mouse(mouse_position, select_max_distance)
		if object != null:
			if _current_hovered_object != null:
				_current_hovered_object.stop_hover()
			_current_hovered_object = object
			_current_hovered_object.hover()
		elif _current_hovered_object != null:
			_current_hovered_object.stop_hover()
			_current_hovered_object = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		var objects_node = _objects.get_children()
		var objects:Array[Node3D] = []
		for obj in objects_node:
			if obj is GameObject:
				objects.append(obj as Node3D)
		var tex = _win_viewport.take_picture(objects)
		#_cam_target.texture = tex
	
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
			if _current_hovered_object != null:
				select(_current_hovered_object)
				get_viewport().set_input_as_handled()
		elif _current_selected_object != null and _current_selected_object.is_not_colliding():
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
	elif event.is_action_pressed("reload_game"):
		GameState.current_game_state = Enum.GameState.FREE_CAMERA
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file(main_menu_scene)
	
	_handle_selected_object_input(event)
	

func _handle_selected_object_input(event: InputEvent) -> void:
	if _current_selected_object == null:
		return
	## Handle selected object resize	
	if event.is_action("scale_up"):
		if _scaling_gauge.can_pay(_current_selected_object.scaling_cost):
			if _current_selected_object.scale_up():
				_scaling_gauge.pay(_current_selected_object.scaling_cost)
				_hud.on_object_scale_changed(_current_selected_object.object_scale)
	elif event.is_action("scale_down"):
		if not _scaling_gauge.isFull():
			if _current_selected_object.scale_down():
				_scaling_gauge.restore(_current_selected_object.scaling_cost)
				_hud.on_object_scale_changed(_current_selected_object.object_scale)


func _unselect_current_object() -> void:
	assert (_current_selected_object!=null, "Trying to unselect an object but none is selected, something is wrong!")
	
	_current_selected_object.selected = false
	GameState.current_game_state = Enum.GameState.FREE_CAMERA
	_current_selected_object = null
	_player_camera.detach_object()
	_hud.on_unselect_object()


func _on_max_height_changed(max_height: float) -> void:
	_billboard.set_max_height(max_height)
	_current_height = max_height


func start_game() -> void:
	_has_won = false
	for i in range(GameSettings.number_items_to_spawn):
		var obj_scene:PackedScene = object_pool.pick_random()
		var rand_x:Vector3 = _spawn_borders.curve.sample(0, randf())
		var rand_z:Vector3 = _spawn_borders.curve.sample(1, randf())
		
		var obj := obj_scene.instantiate()
		_objects.add_child(obj)
		obj.global_position = Vector3(rand_x.x, rand_x.y, rand_z.z)
		#await get_tree().create_timer(0.1).timeout

func win() -> void:
	_has_won = true
	AudioManager.play_music(SoundBank.win_music)
	_hud.show_win()

func select(object: GameObject) -> void:
	if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
		GameState.current_game_state = Enum.GameState.OBJECT_SELECTED
		
		_hud.on_select(object)
		object.global_position = _player_camera.global_position + _player_camera.get_forward_direction() * (object.global_position - _player_camera.global_position).length()
		# tween way, commented out for now
		#var new_object_position: Vector3 = _player_camera.global_position + _player_camera.get_forward_direction() * (object.global_position - _player_camera.global_position).length()
		#var tween: Tween = get_tree().create_tween()
		#tween.tween_property(object, "global_position", new_object_position, 0.1)
		#await tween.finished
		object.selected = true
		_current_selected_object = object
		
		AudioManager.play_sound_effect(SoundBank.grab_se)
		
		_player_camera.attach_object(object.global_position, _player_camera.get_path_to(object))


func _no_object_has_moved_last_frame() -> bool:
	var no_movement = true
	for object: GameObject in _objects.get_children():
		if not object.global_position.is_equal_approx(_last_frame_object_position[object]):
			no_movement = false
		_last_frame_object_position[object] = object.global_position
		
	return no_movement
