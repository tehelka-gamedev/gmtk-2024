class_name PlayerCamera
extends Node3D


const CAMERA_X_ROT_MIN: float = deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX: float = deg_to_rad(70)

@export var translation_speed: float = 10.0
@export var rotation_speed: float = 0.001

@onready var _camera_rotation: Node3D = $CameraRotation


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
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
	
	position += translation_speed * delta * motion_vector # $CameraRotation/Camera3D.global_transform
	#print($CameraRotation/Camera3D.global_transform)


func _input(event: InputEvent) -> void:
	# Handle focus/unfocus with escape / click on the viewport
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if (
			event is InputEventMouseButton
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
			and (event as InputEventMouseButton).pressed
	):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	# If no focus on the window, ignore
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
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
