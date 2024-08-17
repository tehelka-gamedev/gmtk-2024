class_name Billboard
extends StaticBody3D


@onready var _height_label: Label3D = $HeightLabel


func change_max_height(max_height: float) -> void:
	var float_precision: float = pow(10, -Const.HEIGHT_DECIMAL_PRECISION)
	_height_label.text = str(
			snappedf(max_height, float_precision)
	).pad_decimals(Const.HEIGHT_DECIMAL_PRECISION)
