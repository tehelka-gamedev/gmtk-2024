class_name GameObject
extends RigidBody3D


@export var mouse_sensitivity:float = 0.05
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
			mesh_instance.get_surface_override_material(0).albedo_color = Color.WHITE
	get:
		return selected

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_detector: Area3D = $CollisionDetector


func _unhandled_input(event: InputEvent) -> void:
	if not selected:
		return
	
	if (Input.is_action_pressed("allow_object_rotation")
		and event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	):
		rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity))
		rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity))

		var object_rot = rotation_degrees
		object_rot.x = clamp(object_rot.x, -70, 70)
		rotation_degrees = object_rot


func _process(delta: float) -> void:
	if selected:
		if is_not_colliding():
			mesh_instance.get_surface_override_material(0).albedo_color = valid_color
		else:
			mesh_instance.get_surface_override_material(0).albedo_color = invalid_color


func is_not_colliding() -> bool:
	return _collision_detector.get_overlapping_bodies() == []
