class_name HeightDetector
extends ShapeCast3D


signal max_height_changed(max_height: float)

@onready var _timer: Timer = $Timer


func _ready() -> void:
	set_physics_process(false)
	target_position = -position
	_detect_current_max_height()
	@warning_ignore("return_value_discarded")
	_timer.timeout.connect(_detect_current_max_height)


func _detect_current_max_height() -> void:
	force_shapecast_update()
	var max_height: float = 0.0
	for collision: Dictionary in collision_result:
		if collision.point.y > max_height:
			max_height = collision.point.y

	max_height_changed.emit(max_height)
