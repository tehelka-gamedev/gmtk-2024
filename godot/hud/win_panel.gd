extends PanelContainer

@export var stats_zone:StatsZone = null
@export var photo_zone:PhotoZone = null
@export var button_replay:ButtonWithSound = null
@export var button_menu:ButtonWithSound = null

@export_file("*.tscn") var main_menu_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_replay.pressed.connect(func():
		Events.replay_requested.emit()
	)
	button_menu.pressed.connect(_on_button_menu_pressed)


func setup_win(win_stats:WinStats, photo:Texture2D) -> void:
	stats_zone.set_stats(win_stats)
	
	# set the photo
	photo_zone.set_photo(photo)
	
func _on_button_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)
