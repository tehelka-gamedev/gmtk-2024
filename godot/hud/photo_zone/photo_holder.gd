class_name PhotoHolder
extends TextureRect

@onready var photo_content:TextureRect = $PhotoContent

func set_background(new_bg:Texture2D) -> void:
	texture = new_bg

func set_photo(new_photo:Texture2D) -> void:
	photo_content.texture = new_photo
