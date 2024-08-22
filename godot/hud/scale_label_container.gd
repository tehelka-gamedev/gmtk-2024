class_name ScaleLabelContainer
extends PanelContainer


const _scale_label_container_scene: PackedScene = preload("res://hud/scale_label_container.tscn")

@onready var _scale_label: Label = $ScaleLabel

var _scale: float = 1.0
var _current_scale: bool = false


static func new_node(scale: float, current_scale: bool) -> ScaleLabelContainer:
	var scale_label_container: ScaleLabelContainer = _scale_label_container_scene.instantiate()
	scale_label_container._scale = scale
	scale_label_container._current_scale = current_scale
	return scale_label_container


func _ready() -> void:
	_scale_label.text = "%.1f" % _scale
	if _current_scale:
		set_current()
	else:
		unset_current()


func set_current() -> void:
	var new_stylebox_panel: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	new_stylebox_panel.bg_color = Color(Color.RED, 0.5)
	add_theme_stylebox_override("panel", new_stylebox_panel)


func unset_current() -> void:
	var new_stylebox_panel: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	new_stylebox_panel.bg_color = Color(Color.GRAY, 0.5)
	add_theme_stylebox_override("panel", new_stylebox_panel)
