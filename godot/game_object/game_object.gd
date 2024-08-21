class_name GameObject
extends RigidBody3D


@export var mouse_sensitivity: float = 0.05
@export var joystick_sensitivity: float = 3.0
@export_color_no_alpha var hover_color: Color = Color.YELLOW
@export_color_no_alpha var valid_color: Color = Color.GREEN
@export_color_no_alpha var invalid_color: Color = Color.RED
@export var model: Node3D
@export var scale_factor: float = 1 # in pourcentage
@export var approximate_length: float # in meter


@export_category("Gameplay parameters")
## Amount of unit scaling the object cost
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
			_enable_height_line(true)
		else:
			_enable_height_line(false)
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
		mass = _initial_mass * value * value

var _collision_shapes: Array[ScallableCollisionShape3D] = []
var _collision_detector_shapes: Array[ScallableCollisionShape3D] = []
var _mesh_instances: Array[MeshInstance3D] = []

var _initial_mass: float = mass

@onready var _collision_detector: Area3D = $CollisionDetector
@onready var _initial_model_position: Vector3 = model.position
@onready var _height_line: MeshInstance3D = $HeightLine
@onready var _height_ray_cast: RayCast3D = $RayCast3D
@onready var _mass_center: Marker3D = $Mesh/MassCenter
@onready var _height_line_impact: MeshInstance3D = $HeightLineImpact
@onready var _height_line_material: StandardMaterial3D = _height_line.get_surface_override_material(0)


func _ready() -> void:
	_enable_height_line(false)
	
	_initial_mass = mass
	for node: Node in get_children():
		if node is ScallableCollisionShape3D:
			var duplicate: ScallableCollisionShape3D = node.duplicate()
			_collision_detector.add_child(duplicate)
			_collision_shapes.append(node as ScallableCollisionShape3D)
			_collision_detector_shapes.append(duplicate)
	
	_mesh_instances = _get_mesh_instances(self)
	_duplicate_mesh_material()
	center_of_mass = _mass_center.position + _mass_center.get_parent().position


func _unhandled_input(event: InputEvent) -> void:
	if not selected or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if GameState.current_game_state == Enum.GameState.ROTATING_OBJECT and event is InputEventMouseMotion:
		var motion_event:InputEventMouseMotion = event as InputEventMouseMotion
		_rotate_object(motion_event.relative * mouse_sensitivity)


func _physics_process(_delta: float) -> void:
	if not selected:
		return
	if is_not_colliding():
		_set_albedo_color(valid_color)
	else:
		_set_albedo_color(invalid_color)
	
	if GameState.current_game_state == Enum.GameState.ROTATING_OBJECT:
		var rotation_direction: Vector2 = Input.get_vector(
				"rotate_left",
				"rotate_right",
				"rotate_up",
				"rotate_down"
		)
		if not rotation_direction.is_zero_approx():
			_rotate_object(rotation_direction * joystick_sensitivity)
	
	_height_ray_cast.global_rotation = Vector3.ZERO
	_height_ray_cast.force_raycast_update()
	if _height_ray_cast.is_colliding():
		var collision_point: Vector3 = _height_ray_cast.get_collision_point()
		_height_line_impact.global_position = collision_point
		var height_vector: Vector3 = collision_point - global_position
		var line_mesh: CylinderMesh = _height_line.mesh as CylinderMesh
		line_mesh.height = height_vector.length()
		_height_line.global_rotation = Vector3.ZERO
		_height_line.position = (height_vector/2) * global_basis
		_height_line_impact.visible = true
		_height_line.visible = true
	else:
		_height_line.visible = false
		_height_line_impact.visible = false


func is_not_colliding() -> bool:
	return _collision_detector.get_overlapping_bodies() == []

## Not working, WIP
#func is_on_floor() -> bool:
	#_collision_detector.monitoring = true
	#for obj in _collision_detector.get_overlapping_bodies():
		#if obj.name == "Ground":
			#_collision_detector.monitoring = false
			#return true
	#_collision_detector.monitoring = false
	#return false
		

func hover() -> void:
	_set_albedo_color(hover_color)


func stop_hover() -> void:
	_set_albedo_color(Color.WHITE)

## Scale up one time
## Returns true if the scaling could be done, false otherwise
func scale_up() -> bool:
	if object_scale > max_scale:
		return false
	object_scale *= 1 + scale_factor/100
	return true
	
## Scale down one time
## Returns true if the scaling could be done, false otherwise
func scale_down() -> bool:
	if object_scale < min_scale:
		return false
	object_scale /= 1 + scale_factor/100
	return true


func _set_albedo_color(color: Color) -> void:
	for mesh_instance in _mesh_instances:
		var _mesh_instance_override_material: StandardMaterial3D = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
		_mesh_instance_override_material.albedo_color = color
		_height_line_material.albedo_color = Color(color, _height_line_material.albedo_color.a)


func _set_scale(value: float) -> void:
	model.position = _initial_model_position * value
	model.scale = Vector3.ONE * value
	for collision_shape: ScallableCollisionShape3D in _collision_shapes:
		collision_shape.position = collision_shape.initial_position * value
		collision_shape.scale = Vector3.ONE * value
	for collision_shape: ScallableCollisionShape3D in _collision_detector_shapes:
		collision_shape.position = collision_shape.initial_position * value
		collision_shape.scale = Vector3.ONE * value


func _get_mesh_instances(current_node: Node) -> Array[MeshInstance3D]:
	# Tehelka: this is bug prone (problem if current_node is MeshInstance3D and has MeshInstance3D children)
	if current_node is MeshInstance3D and current_node is not HeightLine:
		return [current_node]
	elif current_node.get_child_count() == 0:
		return []

	var array_piece: Array[MeshInstance3D] = []
	for child: Node in current_node.get_children():
		array_piece.append_array(_get_mesh_instances(child))
	
	return array_piece


## Since we change the material color, we duplicate it and link each mesh to it
func _duplicate_mesh_material() -> void:
	if len(_mesh_instances) == 0:
		return
	var mesh_material:StandardMaterial3D = _mesh_instances[0].get_surface_override_material(0).duplicate()
	for mesh in _mesh_instances:
		mesh.set_surface_override_material(0, mesh_material)

func _enable_height_line(value: bool) -> void:
	_height_line.visible = value
	_height_ray_cast.enabled = value
	_height_line_impact.visible = value


func _rotate_object(motion: Vector2) -> void:
	rotate_x(deg_to_rad(motion.y))
	rotate_y(deg_to_rad(motion.x))
