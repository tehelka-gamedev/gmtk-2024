class_name StatsZone
extends MarginContainer

@export var nb_item_picked_label:Label = null
@export var tower_height_label:Label = null

func set_nb_item_picked(value:int) -> void:
	nb_item_picked_label.text = str(value)

func set_tower_height(tower_height:float, target_height:float) -> void:
	tower_height_label.text = "%.2fm/%.2fm" % [ tower_height, target_height ]
	
func set_stats(win_stats:WinStats) -> void:
	set_nb_item_picked(win_stats.nb_item_picked)
	set_tower_height(win_stats.tower_height, win_stats.target_height)
