class_name HUD
extends Control


@onready var _win_panel: PanelContainer = $WinPanel

@onready var object_min_scale: Label = %ObjectMinScale
@onready var object_max_scale: Label = %ObjectMaxScale
@onready var object_scale_gauge: MarginContainer = %ObjectScaleGauge
@onready var object_scale_bar: ProgressBar = %ObjectScaleBar
@onready var object_scale_label: Label = %ObjectScaleLabel

var _selected_object_scale_factor: float

func _ready() -> void:
	_win_panel.visible = false
	object_scale_gauge.visible = false


func show_win(win_stats:WinStats, photo:Texture2D) -> void:
	_win_panel.setup_win(win_stats, photo)
	_win_panel.visible = true


func on_select(object: GameObject) -> void:
	object_min_scale.text = str(object.min_scale)
	object_max_scale.text = str(object.max_scale)
	object_scale_bar.min_value = object.min_scale
	object_scale_bar.max_value = object.max_scale
	object_scale_bar.value = object.object_scale
	_selected_object_scale_factor = object.scale_factor
	object_scale_label.text = "Current object scale: %.2f (object scale growth: %.1f%%)" % [object.object_scale, _selected_object_scale_factor]
	object_scale_gauge.visible = true
	
	
func on_unselect_object() -> void:
	object_scale_gauge.visible = false


func on_object_scale_changed(new_scale: float) -> void:
	object_scale_bar.value = new_scale
	object_scale_label.text = "Current object scale: %.2f (object scale growth: %.1f%%)" % [new_scale, _selected_object_scale_factor]
