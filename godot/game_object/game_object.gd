class_name GameObject
extends RigidBody3D


@export var selected:bool = false :
	set(value):
		selected = value
		freeze = value
		
		if selected:
			mesh_instance.get_surface_override_material(0).albedo_color = selected_color
		else:
			mesh_instance.get_surface_override_material(0).albedo_color = Color.WHITE
			
	get:
		return selected
@export var mouse_sensitivity:float = 0.05
@export_color_no_alpha var selected_color: Color = Color.HOT_PINK

@onready var mesh_instance:MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	if selected:
		freeze = true


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
