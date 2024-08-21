class_name PlayerCamera
extends CharacterBody3D

const CAMERA_X_ROT_MIN: float = deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX: float = deg_to_rad(70)

@export var zoom_speed: float = 5.0
@export var moving_speed: float = 10.0
@export var running_speed: float = 10.0
@export var mouse_rotation_speed: float = 0.001
@export var joystick_rotation_speed: float = 0.05
@export_flags_3d_physics var object_3d_physics_layer: int

var _running: bool = false

@onready var _camera_rotation: Node3D = $CameraRotation
@onready var _camera: Camera3D = $CameraRotation/Camera3D
@onready var _remote_transform3D: RemoteTransform3D = $CameraRotation/RemoteTransform3D


func _process(delta: float) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	var can_move: bool = (GameState.current_game_state == Enum.GameState.FREE_CAMERA
		or GameState.current_game_state == Enum.GameState.OBJECT_SELECTED)
	if not can_move:
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
	
	var movement_speed:float = running_speed if Input.is_action_pressed("run") else moving_speed
	
	velocity = movement_speed * motion_vector
	move_and_slide()
	

	var rotation_direction: Vector2 = Input.get_vector(
			"rotate_left",
			"rotate_right",
			"rotate_up",
			"rotate_down"
	)
	var window: Window = get_viewport() as Window
	var scale_factor: float = min(
			(float(window.size.x) / window.get_visible_rect().size.x),
			(float(window.size.y) / window.get_visible_rect().size.y)
	)
	rotate_camera(rotation_direction * joystick_rotation_speed * scale_factor)

	var attached_object_zoom: float = Input.get_action_strength("zoom_object_in") - Input.get_action_strength("zoom_object_out")
	if not is_zero_approx(attached_object_zoom):
		var zoom_direction: Vector3 = -_camera.global_basis.z
		_remote_transform3D.global_position += zoom_direction * zoom_speed * attached_object_zoom * delta


func _unhandled_input(event: InputEvent) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if GameState.current_game_state == Enum.GameState.ROTATING_OBJECT:
		return
	
	var window: Window = get_viewport() as Window
	var scale_factor: float = min(
			(float(window.size.x) / window.get_visible_rect().size.x),
			(float(window.size.y) / window.get_visible_rect().size.y)
	)

	if event is InputEventMouseMotion:
		rotate_camera((event as InputEventMouseMotion).relative * mouse_rotation_speed * scale_factor)


func attach_object(object_global_position: Vector3, object_path_relative_to_root: NodePath) -> void:
	_remote_transform3D.global_position = object_global_position
	_remote_transform3D.remote_path = NodePath(
			str(_remote_transform3D.get_path_to(self)) + "/" + str(object_path_relative_to_root)
	)


func detach_object() -> void:
	_remote_transform3D.remote_path = NodePath()


func rotate_camera(move: Vector2) -> void:
	rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	orthonormalize()
	_camera_rotation.rotation.x = clamp(_camera_rotation.rotation.x - move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)


func get_object_under_mouse(mouse_position: Vector2, select_max_distance: float) -> GameObject:
	var world_space := get_world_3d().direct_space_state

	var params := PhysicsRayQueryParameters3D.new()
	params.from = _camera.project_ray_origin(mouse_position)
	params.to = _camera.project_position(mouse_position, select_max_distance)
	params.exclude = []
	params.collision_mask = object_3d_physics_layer

	var result:Dictionary = world_space.intersect_ray(params)
	if result and result["collider"] is GameObject:
		return result["collider"]
	return null


func get_forward_direction() -> Vector3:
	return -_camera.global_basis.z
