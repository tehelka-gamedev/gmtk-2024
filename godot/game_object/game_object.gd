class_name GameObject
extends RigidBody3D


@export var scale_sentitivity: float = 1.01
@export var mouse_sensitivity: float = 0.05
@export_color_no_alpha var hover_color: Color = Color.YELLOW
@export_color_no_alpha var valid_color: Color = Color.GREEN
@export_color_no_alpha var invalid_color: Color = Color.RED
@export var scale_pivot: Vector3
@export var model: Node3D

@export_category("Gameplay parameters")
## Amount of unit scaling the object cost
@export var scaling_cost:int = 1
@export var min_scale:float = 0.5
@export var max_scale:float = 2.0

var selected: bool = false :
	set(value):
		selected = value
		freeze = value
		
		if selected:
			_collision_detector.monitoring = true
			_collision_detector.monitorable = true
			collision_layer = 0
		else:
			collision_layer = Enum.CollisionLayer.OBJECT
			_set_albedo_color(Color.WHITE)
			_collision_detector.monitoring = false
			_collision_detector.monitorable = false
	get:
		return selected
var object_scale: float = 1.0:
	set(value):
		object_scale = value
		_set_scale(object_scale)
		mass = _initial_mass * value

var _collision_shapes: Array[ScallableCollisionShape3D] = []
var _collision_detector_shapes: Array[ScallableCollisionShape3D] = []
var _mesh_instances: Array[MeshInstance3D] = []

var _initial_mass:float = mass

@onready var _collision_detector: Area3D = $CollisionDetector
@onready var _initial_model_position: Vector3 = model.position


func _ready() -> void:
	_initial_mass = mass
	for node: Node in get_children():
		if node is ScallableCollisionShape3D:
			var duplicate: ScallableCollisionShape3D = node.duplicate()
			_collision_detector.add_child(duplicate)
			_collision_shapes.append(node as ScallableCollisionShape3D)
			_collision_detector_shapes.append(duplicate)
	
	_mesh_instances = _get_mesh_instances(self)
	center_of_mass = scale_pivot
	#for mesh_instance: MeshInstance3D in _mesh_instances:
		#mesh_instance.set_surface_override_material(0, mesh_instance.get_surface_override_material(0).duplicate())


func _unhandled_input(event: InputEvent) -> void:
	if not selected or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if GameState.current_game_state == Enum.GameState.ROTATING_OBJECT and event is InputEventMouseMotion:
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


func hover() -> void:
	_set_albedo_color(hover_color)


func stop_hover() -> void:
	_set_albedo_color(Color.WHITE)

## Scale up one time
## Returns true if the scaling could be done, false otherwise
func scale_up() -> bool:
	if object_scale*scale_sentitivity > max_scale:
		return false
	object_scale *= scale_sentitivity
	return true
	
## Scale down one time
## Returns true if the scaling could be done, false otherwise
func scale_down() -> bool:
	if object_scale/scale_sentitivity < min_scale:
		return false
	object_scale /= scale_sentitivity
	return true

func _set_albedo_color(color: Color) -> void:
	for mesh_instance in _mesh_instances:
		var _mesh_instance_override_material: StandardMaterial3D = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
		_mesh_instance_override_material.albedo_color = color


func _set_scale(value: float) -> void:
	#for mesh_instance: MeshInstance3D in _mesh_instances:
		#mesh_instance.scale = Vector3.ONE * value
	model.position = scale_pivot + (_initial_model_position - scale_pivot) * value
	model.scale = Vector3.ONE * value
	for collision_shape: ScallableCollisionShape3D in _collision_shapes:
		collision_shape.position = scale_pivot + (collision_shape.initial_position - scale_pivot) * value
		collision_shape.scale = Vector3.ONE * value
	for collision_shape: ScallableCollisionShape3D in _collision_detector_shapes:
		collision_shape.global_position = global_position + scale_pivot + (collision_shape.initial_position - scale_pivot) * value
		collision_shape.scale = Vector3.ONE * value


func _get_mesh_instances(current_node: Node) -> Array[MeshInstance3D]:
	if current_node is MeshInstance3D:
		return [current_node]
	elif current_node.get_child_count() == 0:
		return []

	var array_piece: Array[MeshInstance3D] = []
	for child: Node in current_node.get_children():
		array_piece.append_array(_get_mesh_instances(child))
	
	return array_piece
