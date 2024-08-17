class_name PlayerCamera
extends Node3D

const CAMERA_X_ROT_MIN: float = deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX: float = deg_to_rad(70)

@export var translation_speed: float = 10.0
@export var rotation_speed: float = 0.001
@export_flags_3d_physics var object_3d_physics_layer: int

@onready var _camera_rotation: Node3D = $CameraRotation
@onready var _camera: Camera3D = $CameraRotation/Camera3D
@onready var _remote_transform3D: RemoteTransform3D = $CameraRotation/RemoteTransform3D


func _process(delta: float) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	var can_move:bool = (GameState.current_game_state == Enum.GameState.FREE_CAMERA
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
	
	position += translation_speed * delta * motion_vector


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
		var camera_speed_this_frame: float = rotation_speed
		rotate_camera((event as InputEventMouseMotion).relative * camera_speed_this_frame * scale_factor)


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


func get_object_under_mouse(mouse_position: Vector2) -> GameObject:
	var world_space := get_world_3d().direct_space_state

	var params := PhysicsRayQueryParameters3D.new()
	params.from = _camera.project_ray_origin(mouse_position)
	params.to = _camera.project_position(mouse_position, _camera.far)
	params.exclude = []
	params.collision_mask = object_3d_physics_layer

	var result:Dictionary = world_space.intersect_ray(params)
	if result and result["collider"] is GameObject:
		return result["collider"]
	return null
