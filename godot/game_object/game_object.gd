class_name GameObject
extends RigidBody3D


@export var scale_sentitivity: float = 1.01
@export var mouse_sensitivity: float = 0.05
@export_color_no_alpha var valid_color: Color = Color.GREEN
@export_color_no_alpha var invalid_color: Color = Color.RED

var selected: bool = false :
	set(value):
		selected = value
		freeze = value
		
		if selected:
			collision_layer = 0
		else:
			collision_layer = Enum.CollisionLayer.OBJECT
			_set_albedo_color(Color.WHITE)
	get:
		return selected
var object_scale: float = 1.0:
	set(value):
		object_scale = value
		_set_scale(object_scale)
		_collision_shape.scale = Vector3.ONE * object_scale
		_collision_detector_shape.scale = Vector3.ONE * object_scale

@export var _mesh_instances: Array[MeshInstance3D] = []
@onready var _collision_detector: Area3D = $CollisionDetector
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _collision_detector_shape: CollisionShape3D = $CollisionDetector/CollisionShape3D


func _unhandled_input(event: InputEvent) -> void:
	if not selected or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event.is_action("scale_up"):
		object_scale *= scale_sentitivity
	elif event.is_action("scale_down"):
		object_scale /= scale_sentitivity
	elif GameState.current_game_state == Enum.GameState.ROTATING_OBJECT and event is InputEventMouseMotion:
		var motion_event:InputEventMouseMotion = event as InputEventMouseMotion
		rotate_x(deg_to_rad(motion_event.relative.y * mouse_sensitivity))
		rotate_y(deg_to_rad(motion_event.relative.x * mouse_sensitivity))

		var object_rot:Vector3 = rotation_degrees
		object_rot.x = clamp(object_rot.x, -70, 70)
		rotation_degrees = object_rot


func _process(_delta: float) -> void:
	if selected:
		if is_not_colliding():
			_set_albedo_color(valid_color)
		else:
			_set_albedo_color(invalid_color)


func is_not_colliding() -> bool:
	return _collision_detector.get_overlapping_bodies() == []


func _set_albedo_color(color:Color) -> void:
	for mesh_instance in _mesh_instances:
		var _mesh_instance_override_material:StandardMaterial3D = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
		_mesh_instance_override_material.albedo_color = color

func _set_scale(value:float) -> void:
	for mesh_instance in _mesh_instances:
		mesh_instance.scale = Vector3.ONE * value
