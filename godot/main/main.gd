extends Node3D


@onready var _height_detector: HeightDetector = $HeightDetector
@onready var _billboard: Billboard = $Billboard


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_height_detector.max_height_changed.connect(_on_max_height_changed)


func _on_max_height_changed(max_height: float) -> void:
	_billboard.change_max_height(max_height)
