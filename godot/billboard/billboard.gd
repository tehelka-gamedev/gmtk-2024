class_name Billboard
extends StaticBody3D


@onready var _target_height_label: Label3D = $TargetHeightLabel
@onready var _height_label: Label3D = $HeightLabel


func set_max_height(max_height: float) -> void:
	_height_label.text = "current height: " + height_to_str(max_height) + "m"


func set_target_height(target_height: float) -> void:
	_target_height_label.text = "target height: " + height_to_str(target_height) + "m"


func height_to_str(height: float) -> String:
	var float_precision: float = pow(10, -Const.HEIGHT_DECIMAL_PRECISION)
	return str(snappedf(height, float_precision)).pad_decimals(Const.HEIGHT_DECIMAL_PRECISION)
