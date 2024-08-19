class_name PhotoZone
extends PanelContainer

@onready var photo_holder:PhotoHolder = $MarginContainer/PhotoHolder

func set_photo(new_photo:Texture2D) -> void:
	photo_holder.set_photo(new_photo)
