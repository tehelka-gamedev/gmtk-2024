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
	var txt:String = "Post-import:\tGenerate material for [b]%s[/b] (%s)" % [scene.name, get_source_file()]
	print_rich("\n[bgcolor=BLACK][b]%s[/b][/bgcolor]" % ["=".repeat(txt.length()) ])
	print_rich(txt)
	scene_name = scene.name
	
	var base_dir = "%s/%s" % [
		get_source_file().get_base_dir(),
		TEXTURE_FOLDER
		]
	var base_path = "%s/%s" % [
		base_dir,
		scene_name,
		]
	
	mat = StandardMaterial3D.new()
	
	mat.albedo_texture = find_texture(base_dir, "_BaseColor.png")
	mat.ambiant_occlusion_enabled = true
	mat.ambiant_occlusion = find_texture(base_dir, "_AO.png")
	mat.normal_enabled = true
	mat.normal_texture = find_texture(base_dir, "_Normal.png")
	mat.roughness_texture = find_texture(base_dir, "_Roughness.png")
	mat.metallic_texture = find_texture(base_dir, "_Metallic.png")
	mat.heightmap_enabled = true
	mat.heightmap_texture = find_texture(base_dir, "_Height.exr")
	mat.heightmap_flip_texture = true
	mat.resource_local_to_scene = true
	
	var output_mat_path := "%s/%s.material" % [
		get_source_file().get_base_dir(),
		get_source_file().get_basename().split("/")[-1]
	]
	print_color("GREEN", "Post-import:\tSave material [b]%s[/b]" % [output_mat_path])
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

func find_texture(base_dir:String, end_name:String) -> Resource:
	for f_name in DirAccess.get_files_at(base_dir):
		if f_name.ends_with(end_name):
			var res_path:String = "%s/%s" % [base_dir, end_name]
			print_color("ORANGE", "\tLoading resource '%s'" % [res_path])
			return load(res_path)
			
	print_color("RED", "Could not find %s in %s." % [end_name, base_dir])
	return null

func print_color(color:String, txt:String) -> void:
	print_rich("[color=%s]%s[color=#ffffff]" % [color, txt])
