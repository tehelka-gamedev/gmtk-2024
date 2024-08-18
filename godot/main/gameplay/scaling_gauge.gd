class_name Gauge
extends Node

signal gauge_value_changed(new_value:int)
signal gauge_max_value_changed(new_value:int)

const MIN_VALUE:int = 0

## Max value of the gauge
@export var max_value:int = 100 :
	set(_value):
		max_value = _value
		gauge_max_value_changed.emit(max_value)

## Starting value of the gauge
@export var _initial_value:int = max_value

var current_value = _initial_value :
	set(_value):
		current_value = clamp(_value, MIN_VALUE, max_value)
		gauge_value_changed.emit(current_value)

func _ready() -> void:
	current_value = _initial_value
	
func isEmpty() -> bool:
	return current_value > 0

func isFull() -> bool:
	return current_value == max_value
