extends Node3D


@onready var _height_detector: HeightDetector = $HeightDetector
@onready var _billboard: Billboard = $Billboard
@onready var player_camera:PlayerCamera = $PlayerCamera

func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_height_detector.max_height_changed.connect(_on_max_height_changed)
	
	player_camera.object_clicked.connect(_on_object_clicked)

func _on_max_height_changed(max_height: float) -> void:
	_billboard.change_max_height(max_height)

func _on_object_clicked(object:GameObject) -> void:
	GameState.current_game_state = Enum.GameState.OBJECT_SELECTED
	object.selected = not object.selected
