class_name ButtonWithSound
extends Button

@export var sound_on_click:AudioStream = preload("res://audio/data/snd_click.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	if sound_on_click != null:
		button_down.connect(func():
			# AudioManager.PlaySoundEffect(sound_on_click)
			pass
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
