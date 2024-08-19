class_name HUD
extends Control


@onready var _win_panel: PanelContainer = $WinPanel


func _ready() -> void:
	_win_panel.visible = false


func show_win(win_stats:WinStats, photo:Texture2D) -> void:
	_win_panel.setup_win(win_stats, photo)
	_win_panel.visible = true
