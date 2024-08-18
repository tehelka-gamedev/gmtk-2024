@tool # Needed so it runs in editor.
extends EditorScenePostImport

const TEXTURE_FOLDER = "Texture_export"
const SURFACE_MATERIAL_IDX = 0

var scene_name:String = ""

var mat:StandardMaterial3D = null

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	print_rich("\n[b]============================================[/b]")
	print_rich("Post-import:\tGenerate material for [b]%s[/b] (%s)" % [scene.name, get_source_file()])
	scene_name = scene.name
	
	var base_dir = "%s/%s" % [
		get_source_file().get_base_dir(),
		TEXTURE_FOLDER
		]
	var base_path = "%s/%s" % [
		base_dir,
		scene_name,
		]
	print("base_path : %s" % base_path)
	
	
	mat = StandardMaterial3D.new()
	mat.albedo_texture = load("%s_BaseColor.png" % base_path )
	mat.ambiant_occlusion_enabled = true
	mat.ambiant_occlusion = load("%s_AO.png" % base_path )
	mat.normal_enabled = true
	mat.normal_texture = load("%s_Normal.png" % base_path )
	mat.roughness_texture = load("%s_Roughness.png" % base_path )
	mat.metallic_texture = load("%s_Metallic.png" % base_path )
	mat.heightmap_enabled = true
	mat.heightmap_texture = load("%s_Height.exr" % base_path )
	mat.heightmap_flip_texture = true
	mat.resource_local_to_scene = true
	
	var output_mat_path := "%s/%s.material" % [
		get_source_file().get_base_dir(),
		get_source_file().get_basename().split("/")[-1]
	]
	print_rich("Post-import:\tSave material [b]%s[/b]" % [output_mat_path])
	ResourceSaver.save(mat, output_mat_path)
	
	iterate(scene)
	return scene # Remember to return the imported scene

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node):
	if node != null:
		if node is MeshInstance3D:
			node.set_surface_override_material(SURFACE_MATERIAL_IDX, mat)
			

		for child in node.get_children():
			iterate(child)
