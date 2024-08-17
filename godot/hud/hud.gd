class_name HUD
extends Control


@onready var _win_label: Label = $WinLabel


func _ready() -> void:
	_win_label.visible = false


func show_win() -> void:
	_win_label.visible = true
