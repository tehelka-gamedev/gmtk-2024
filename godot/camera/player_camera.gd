class_name PlayerCamera
extends Node3D

signal object_clicked(obj:GameObject)

const CAMERA_X_ROT_MIN: float = deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX: float = deg_to_rad(70)

@export var translation_speed: float = 10.0
@export var rotation_speed: float = 0.001

@export_flags_3d_physics var object_3d_physics_layer

@onready var _camera_rotation: Node3D = $CameraRotation
@onready var _camera: Camera3D = $CameraRotation/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
		
	if GameState.current_game_state != Enum.GameState.FREE_CAMERA:
		return
	
	var horizontal_input_vector: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)
	var vertical_input: float = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	
	var motion_vector: Vector3 = (
		horizontal_input_vector.x * _camera_rotation.global_basis.x
		+ vertical_input * _camera_rotation.global_basis.y
		+ horizontal_input_vector.y * _camera_rotation.global_basis.z
	)
	
	position += translation_speed * delta * motion_vector


func _input(event: InputEvent) -> void:
	# Handle focus/unfocus with escape / click on the viewport
	if event.is_action_pressed("ui_cancel"):
		if GameState.current_game_state == Enum.GameState.FREE_CAMERA:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_viewport().set_input_as_handled()
		elif GameState.current_game_state == Enum.GameState.OBJECT_SELECTED:
			pass
	if (
			event is InputEventMouseButton
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
			and (event as InputEventMouseButton).pressed
	):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
		elif GameState.current_game_state == Enum.GameState.FREE_CAMERA:
			var obj := get_object_under_mouse(event.position)
			if obj and obj is GameObject:
				obj = obj as GameObject
				object_clicked.emit(obj)
				get_viewport().set_input_as_handled()
				

func get_object_under_mouse(mouse_position:Vector2) -> Node3D:
		var world_space := get_world_3d().direct_space_state
 
		var params := PhysicsRayQueryParameters3D.new()
		params.from = _camera.project_ray_origin(mouse_position)
		params.to = _camera.project_position(mouse_position, _camera.far)
		params.exclude = []
		params.collision_mask = object_3d_physics_layer
 
		var result:Dictionary = world_space.intersect_ray(params)
		if result:
			return result["collider"]
		return null

func _unhandled_input(event: InputEvent) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if GameState.current_game_state != Enum.GameState.FREE_CAMERA:
		return
	
	var window: Window = get_viewport() as Window
	var scale_factor: float = min(
			(float(window.size.x) / window.get_visible_rect().size.x),
			(float(window.size.y) / window.get_visible_rect().size.y)
	)

	if event is InputEventMouseMotion:
		var camera_speed_this_frame: float = rotation_speed
		rotate_camera((event as InputEventMouseMotion).relative * camera_speed_this_frame * scale_factor)


func rotate_camera(move: Vector2) -> void:
	rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	orthonormalize()
	_camera_rotation.rotation.x = clamp(_camera_rotation.rotation.x - move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
