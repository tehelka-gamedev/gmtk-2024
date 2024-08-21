extends Control

@export var button_play:Button = null
@export var button_credits:Button = null
@export var button_quit:Button = null
@export var button_how_to_play:Button = null
@export var play_scene:PackedScene = null
@export var levels_container:BoxContainer = null
@export var levels: Array[PackedScene]
@export var credit_panel:PanelContainer = null
@export var how_to_play_panel:PanelContainer = null

# logo anim
@export var title_logo:TextureRect = null
var tween:Tween = null
@export var menu_controls_to_hide:Array[Control] = []

@export_category("Debug variables")
@export var nb_item_slider:Slider = null
@export var nb_item_label:Label = null
@export var target_height_slider:Slider = null
@export var target_height_label:Label = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	how_to_play_panel.visible = false
	if not OS.has_feature("editor"):
		_animate_logo()
	AudioManager.play_music(SoundBank.main_menu_music)
	
	if play_scene != null:
		button_play.pressed.connect(func():
			AudioManager.stop_music()
			get_tree().change_scene_to_packed(play_scene)
		)
	else:
		push_error("No scene set for play button, cannot play !")
	
	button_credits.pressed.connect(show_credits)
	button_how_to_play.pressed.connect(show_how_to_play)
	
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
	
	var level_number: int = 0
	for level: PackedScene in levels:
		level_number += 1
		var button: ButtonWithSound = ButtonWithSound.new()
		for i: int in level.get_state().get_node_property_count(0):
			if level.get_state().get_node_property_name(0, i) == "level_name":
				button.text = str(level_number) + ". " + str(level.get_state().get_node_property_value(0, i))
		button.pressed.connect(func():
			get_tree().change_scene_to_packed(level)
		)
		levels_container.add_child(button)

func show_credits() -> void:
	credit_panel.show()
	
func show_how_to_play() -> void:
	how_to_play_panel.show()

func play_logo_impact_sound() -> void:
	AudioManager.play_sound_effect(SoundBank.impact_wood)


func _animate_logo() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	#tween.tween_interval(1.0)
	for obj in menu_controls_to_hide:
		obj.modulate.a = 0
	
	var end_y:float = title_logo.global_position.y
	var start_y:float = end_y-256
	tween.tween_property(title_logo, "position:y", end_y, 2.2).from(start_y).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(AudioManager.play_sound_effect.bind(SoundBank.impact_wood))
	tween.set_parallel(true)
	for obj in menu_controls_to_hide:
		tween.tween_property(obj, "modulate:a", 1, 1.0).from(0)
	tween.set_parallel(false)
	tween.tween_callback(show_how_to_play)
	
	#await tween.finished
	#AudioManager.play_sound_effect(SoundBank.impact_wood)
	#tween.stop()

	
