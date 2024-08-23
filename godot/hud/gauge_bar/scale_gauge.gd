class_name ScaleGauge
extends MarginContainer


@onready var _gauge_unit_container: VBoxContainer = $VBoxContainer/MarginContainer/GaugeUnitContainer

var _current_gauge_value: int = 0
var _gauge_bar_units: Array[GaugeBarUnit] = []


func init_gauge(bar_unit_number: int, current_gauge_value: int) -> void:
	for i: int in range(bar_unit_number):
		var is_new_bar_unit_full: bool = bar_unit_number - i - 1 < current_gauge_value
		var gauge_bar_unit: GaugeBarUnit = GaugeBarUnit.new_node(is_new_bar_unit_full)
		_gauge_bar_units.append(gauge_bar_unit)
		_gauge_unit_container.add_child(gauge_bar_unit)
	_current_gauge_value = current_gauge_value


func on_gauge_value_changed(new_value: int) -> void:
	if new_value > _current_gauge_value:
		for i: int in range(new_value - _current_gauge_value):
			_gauge_bar_units[len(_gauge_bar_units) - 1 - _current_gauge_value + i].set_full()
	else:
		for i: int in range(_current_gauge_value - new_value):
			_gauge_bar_units[len(_gauge_bar_units) - 1 - new_value + i].set_empty()
	_current_gauge_value = new_value
