extends Node3D


const TIME_BEFORE_WIN_WHEN_HEIGHT_IS_OVER_TARGET: float = 5.0

@export var target_height: float = 5.0
@export var select_max_distance: float = 5.0
@export var no_movement_duration_before_game_win: float = 3.0
@export var level_name: String
@export var sandbox_mode: bool = true
@export_file("*.tscn") var main_menu_scene: String
@export_dir var game_object_folder: String

var _current_height: float = 0.0
var _last_time_something_has_moved: float = 0.0
var _current_selected_object: GameObject = null
var _current_hovered_object: GameObject = null
var _last_frame_object_position: Dictionary = {}
var _last_time_height_changed: float = 0.0

## True if the player has won, false otherwise
var _has_won:bool = false

## tracks player stats
var _stats:WinStats = WinStats.new()

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
	AudioManager.play_music(SoundBank.game_music, 1)
	
	Events.unpause_game.connect(func():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
	
	if not Events.replay_requested.is_connected(reload_level):
		Events.replay_requested.connect(reload_level)
		
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
	_last_time_height_changed += delta
	if not _has_won and _current_height >= target_height:
		if _no_object_has_moved_last_frame():
			_last_time_something_has_moved += delta
		
		if (_last_time_something_has_moved >= no_movement_duration_before_game_win
			or _last_time_height_changed >= TIME_BEFORE_WIN_WHEN_HEIGHT_IS_OVER_TARGET):
			win()

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if _current_selected_object == null:
		var mouse_position: Vector2 = get_viewport().get_visible_rect().size / 2
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
		var photo = await _win_viewport.take_picture(objects)
		$camTarget.texture = photo
	
	# Handle focus/unfocus with escape / click on the viewport
	if event.is_action_pressed("pause_menu"):
		if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
			Events.pause()
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
	
	_handle_selected_object_input(event)
	

func _handle_selected_object_input(event: InputEvent) -> void:
	if _current_selected_object == null:
		return
	## Handle selected object resize	
	if event.is_action_pressed("scale_up"):
		if _scaling_gauge.can_pay(1.0):
			if _current_selected_object.scale_up():
				_scaling_gauge.pay(1.0)
				_hud.on_object_scale_changed(
						_current_selected_object.scale_factors,
						_current_selected_object.current_scale_factors_idx
				)
	elif event.is_action_pressed("scale_down"):
		if not _scaling_gauge.isFull():
			if _current_selected_object.scale_down():
				_scaling_gauge.restore(1.0)
				_hud.on_object_scale_changed(
						_current_selected_object.scale_factors,
						_current_selected_object.current_scale_factors_idx
				)
				

func _unselect_current_object() -> void:
	assert (_current_selected_object!=null, "Trying to unselect an object but none is selected, something is wrong!")
	AudioManager.play_sound_effect(SoundBank.drop_se)
	_current_selected_object.selected = false
	GameState.current_game_state = Enum.GameState.FREE_CAMERA
	_current_selected_object = null
	_player_camera.detach_object()
	_hud.on_unselect_object()


func _on_max_height_changed(max_height: float) -> void:
	_billboard.set_max_height(max_height)
	_last_time_height_changed = 0.0
	_current_height = max_height


func reload_level() -> void:
	get_tree().reload_current_scene()
	
	
func start_game() -> void:
	var object_pool: Array[PackedScene] = _get_object_scenes()
	_has_won = false
	_stats.reset()
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
	_stats.tower_height = _current_height
	_stats.target_height = target_height
	_win_viewport.camera_distance = target_height
	
	var objects_node = _objects.get_children()
	var objects:Array[Node3D] = []
	for obj in objects_node:
		if obj is GameObject:
			objects.append(obj as Node3D)
	var photo = await _win_viewport.take_picture(objects)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	_hud.show_win(_stats, photo)


func select(object: GameObject) -> void:
	# Picking object
	if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
		GameState.current_game_state = Enum.GameState.OBJECT_SELECTED
		
		_hud.on_select_object(object.scale_factors, object.current_scale_factors_idx)
		object.global_position = _player_camera.global_position + _player_camera.get_forward_direction() * (object.global_position - _player_camera.global_position).length()
		# tween way, commented out for now
		#var new_object_position: Vector3 = _player_camera.global_position + _player_camera.get_forward_direction() * (object.global_position - _player_camera.global_position).length()
		#var tween: Tween = get_tree().create_tween()
		#tween.tween_property(object, "global_position", new_object_position, 0.1)
		#await tween.finished
		object.selected = true
		_current_selected_object = object
		
		AudioManager.play_sound_effect(SoundBank.grab_se)
		_stats.nb_item_picked += 1
		
		_player_camera.attach_object(object.global_position, _player_camera.get_path_to(object))


func _no_object_has_moved_last_frame() -> bool:
	var no_movement = true
	for object: GameObject in _objects.get_children():
		if not object.global_position.is_equal_approx(_last_frame_object_position[object]):
			no_movement = false
		_last_frame_object_position[object] = object.global_position
		
	return no_movement


func _get_object_scenes() -> Array[PackedScene]:
	var object_scenes: Array[PackedScene] = []
	for directory: String in DirAccess.get_directories_at(game_object_folder):
		if directory.contains("DEBUG"):
			continue
		var scene_file: String = _get_object_scene(directory)
		if scene_file != "":
			object_scenes.append(load(game_object_folder + "/" + directory + "/" + scene_file))
	return object_scenes
		

func _get_object_scene(directory: String) -> String:
	# Cette fonction permet de définier des scènes GameObject qui
	# ne seront utilisées que si le moteur physics est jolt
	# Il suffit simplement de prendre une scène GameObject et de l'enregistrer sous 
	# le nom {OBJECT_NAME}_jolt.tscn dans le dosier res://game_object/{OBJECT_NAME} correspondant
	var physics_engine_is_jolt: bool = ProjectSettings.get_setting("physics/3d/physics_engine") == "JoltPhysics3D"
	var scene_file: String = ""
	for file: String in DirAccess.get_files_at(game_object_folder + "/" + directory):
		if not file.ends_with(".tscn"):
			continue
		if file.ends_with("jolt.tscn"):
			if physics_engine_is_jolt:
				return file
			else:
				continue
		else:
			scene_file = file
	return scene_file
