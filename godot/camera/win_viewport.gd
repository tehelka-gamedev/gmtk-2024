class_name WinViewport
extends SubViewport

@export var camera_distance:float = 10
@onready var screenshot_camera:Camera3D = $ScreenshotCamera

func take_picture(objects:Array[Node3D]) -> Texture:
	_place_camera(objects)
	
	var img = get_texture().get_image()
	# Convert Image to ImageTexture.
	var tex = ImageTexture.create_from_image(img)
	# Return sprite texture.
	return tex


func _place_camera(objects:Array[Node3D]) -> void:
	## Compute barycenter of all objects
	var barycenter:Vector3 = Vector3.ZERO
	
	for obj in objects:
		barycenter += obj.global_position
	barycenter /= objects.size()
	
	## Place the camera on a sphere at a distance r = camera_distance
	## within certain angle
	## (use mathematical conventions, see https://en.wikipedia.org/wiki/Spherical_coordinate_system)
	var r:float = camera_distance
	var theta:float = randf_range(2*PI/8, 3*PI/8)
	var phi:float = randf_range(0, 2*PI)
	
	## Generate a spherical coordinate on the sphere
	## Then change it to the cartesian coordinates
	# Wikipedia use Vector3(A, B, C) to compute the cartesian coordinates
	# but here it worked with the order BCA. Probably because we have Y up
	# so we had to change the basis. /shrug
	var A = r * sin(theta)*cos(phi)
	var B = r * sin(theta) * sin(phi)
	var C = r * cos(theta)
	
	var camera_position:Vector3 = barycenter + Vector3(
		B,
		C,
		A,
	)

	screenshot_camera.look_at_from_position(camera_position, barycenter)
