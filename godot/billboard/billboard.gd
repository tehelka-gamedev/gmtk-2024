
class_name Billboard
extends StaticBody3D


var _elapsed_time: float = 0.0
@onready var _target_height_label: Label3D = $TargetHeightLabel
@onready var _height_label: Label3D = $HeightLabel
@onready var _initial_y: float = position.y

func _physics_process(delta: float) -> void:
	_elapsed_time += delta
	if _elapsed_time > 2*PI:
		_elapsed_time - 2*PI
	position.y = _initial_y + sin(_elapsed_time)/4
	

func set_max_height(max_height: float) -> void:
	_height_label.text = "Current height: " + height_to_str(max_height) + "m"


func set_target_height(target_height: float) -> void:
	_target_height_label.text = "Target height: " + height_to_str(target_height) + "m"


func height_to_str(height: float) -> String:
	var float_precision: float = pow(10, -Const.HEIGHT_DECIMAL_PRECISION)
	return str(snappedf(height, float_precision)).pad_decimals(Const.HEIGHT_DECIMAL_PRECISION)
