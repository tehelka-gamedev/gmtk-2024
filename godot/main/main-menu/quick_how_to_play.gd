extends PanelContainer

@export var quit_button:Button = null

func _ready() -> void:
	quit_button.pressed.connect(func():
		queue_free()
	)
