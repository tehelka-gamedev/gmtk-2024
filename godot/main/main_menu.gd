extends Control

@export var button_play:Button = null
@export var button_quit:Button = null
@export var play_scene:PackedScene = null

@export_category("Debug variables")
@export var nb_item_slider:Slider = null
@export var nb_item_label:Label = null
@export var target_height_slider:Slider = null
@export var target_height_label:Label = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if play_scene != null:
		button_play.pressed.connect(func():
			get_tree().change_scene_to_packed(play_scene)
		)
	else:
		push_error("No scene set for play button, cannot play !")
	
	if OS.has_feature("web"):
		button_quit.queue_free()
	else:
		button_quit.pressed.connect(func():
			get_tree().quit()
			)

	## Debug ##
	
	
	target_height_slider.value_changed.connect(func(value:float):
		GameSettings.target_height = value
		target_height_label.text = "%.2fm" % value
	)
	
	nb_item_slider.value_changed.connect(func(value:float):
		GameSettings.number_items_to_spawn = int(value)
		nb_item_label.text = "%d" % int(value)
	)
	
	print("%d" % int(GameSettings.number_items_to_spawn))
	
	target_height_slider.value = GameSettings.target_height
	nb_item_slider.value = GameSettings.number_items_to_spawn
	nb_item_label.text = "%d" % int(nb_item_slider.value)
