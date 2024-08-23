class_name GaugeBarUnit
extends ProgressBar


const _gauge_bar_unit_scene: PackedScene = preload("res://hud/gauge_bar/gauge_bar_unit.tscn")

var _is_full: bool = false


static func new_node(is_full: bool) -> GaugeBarUnit:
	var _gauge_bar_unit: GaugeBarUnit = _gauge_bar_unit_scene.instantiate()
	_gauge_bar_unit._is_full = is_full
	return _gauge_bar_unit


func _ready() -> void:
	if _is_full:
		set_full()
	else:
		set_empty()


func set_full() -> void:
	var new_stylebox_panel: StyleBoxFlat = get_theme_stylebox("background").duplicate()
	new_stylebox_panel.bg_color = Color(Color.WHITE, 1.0)
	add_theme_stylebox_override("background", new_stylebox_panel)
	value = 1


func set_empty() -> void:
	var new_stylebox_panel: StyleBoxFlat = get_theme_stylebox("background").duplicate()
	new_stylebox_panel.bg_color = Color(Color.DIM_GRAY, 1.0)
	add_theme_stylebox_override("background", new_stylebox_panel)
	value = 0
