extends Control

@export var button_play:Button = null
@export var button_credits:Button = null
@export var button_quit:Button = null
@export var play_scene:PackedScene = null
@export var levels_container:BoxContainer = null
@export var levels: Array[PackedScene]

@export_category("Debug variables")
@export var nb_item_slider:Slider = null
@export var nb_item_label:Label = null
@export var target_height_slider:Slider = null
@export var target_height_label:Label = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(SoundBank.main_menu_music)
	
	if play_scene != null:
		button_play.pressed.connect(func():
			AudioManager.stop_music()
			get_tree().change_scene_to_packed(play_scene)
		)
	else:
		push_error("No scene set for play button, cannot play !")
	
	button_credits.pressed.connect(show_credits)
	
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
	
	target_height_slider.value = GameSettings.target_height
	nb_item_slider.value = GameSettings.number_items_to_spawn
	nb_item_label.text = "%d" % int(nb_item_slider.value)
	
	
	for level: PackedScene in levels:
		var button: ButtonWithSound = ButtonWithSound.new()
		for i: int in level.get_state().get_node_property_count(0):
			if level.get_state().get_node_property_name(0, i) == "level_name":
				button.text = str(level.get_state().get_node_property_value(0, i))
		button.pressed.connect(func():
			get_tree().change_scene_to_packed(level)
		)
		levels_container.add_child(button)

func show_credits() -> void:
	pass
