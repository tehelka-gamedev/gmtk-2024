class_name HUD
extends Control

@export var pause_menu:PauseMenu = null

@onready var _win_panel: PanelContainer = $WinPanel
@onready var _scale_factor_container: HBoxContainer = %ScaleFactorContainer

@onready var object_scale_container: MarginContainer = %ObjectScaleContainer
@onready var object_scale_label: Label = %ObjectScaleLabel

var _scale_label_containers: Array[ScaleLabelContainer] = []
var _current_scale_factor_idx: int = 0


func _ready() -> void:
	_win_panel.visible = false
	object_scale_container.visible = false


func show_win(win_stats:WinStats, photo:Texture2D) -> void:
	_win_panel.setup_win(win_stats, photo)
	_win_panel.visible = true


func on_select_object(scale_factors: Array[float], current_scale_factors_idx: int) -> void:
	for i: int in len(scale_factors):
		var is_current_scale: bool = i == current_scale_factors_idx
		var scale_label_container: ScaleLabelContainer = ScaleLabelContainer.new_node(
				scale_factors[i],
				is_current_scale
		)
		_scale_label_containers.append(scale_label_container)
		_scale_factor_container.add_child(scale_label_container)

	_current_scale_factor_idx = current_scale_factors_idx
	object_scale_container.visible = true
	
	
func on_unselect_object() -> void:
	object_scale_container.visible = false
	for _scale_label_container: ScaleLabelContainer in _scale_label_containers:
		_scale_label_container.queue_free()
	_scale_label_containers = []


func on_object_scale_changed(scale_factors: Array[float], new_scale_idx: int) -> void:
	_scale_label_containers[_current_scale_factor_idx].unset_current()
	_current_scale_factor_idx = new_scale_idx
	_scale_label_containers[new_scale_idx].set_current()
	
