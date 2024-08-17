class_name AttachArm
extends Node3D


var attached_object: GameObject:
	set(value):
		attached_object = value
		if attached_object != null:
			set_physics_process(true)
			var force_vector: Vector3 = global_position - attached_object.global_position
			attached_object.apply_central_impulse(force_vector * 10)
		else:
			set_physics_process(false)


func _ready() -> void:
	set_physics_process(false)
	


func _physics_process(delta: float) -> void:
	return
	var force_vector: Vector3 = global_position - attached_object.global_position
	print(force_vector.length())
	if force_vector.length() < 0.1:
		return
	attached_object.apply_central_force(force_vector * 1000)
	
