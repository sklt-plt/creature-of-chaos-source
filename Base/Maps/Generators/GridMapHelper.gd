extends Spatial
class_name GridMapHelper

static func configure_surface_type(var gmap : GridMap):
	var effect = gmap.mesh_library.get_item_mesh(0).surface_get_material(0).get("hit_effect")
	if effect:
		var type_node = SurfaceHitEffectType.new()
		type_node.effect = effect
		type_node.name = "SurfaceHitEffectType"

		gmap.add_child(type_node)
		type_node.owner = gmap.owner
		return

	print("Warning: not found surface type for mesh library: ", gmap.mesh_library.resource_path)

static func configure_gridmap(var room_geometry: RoomGeometry, var tiles: MeshLibrary):
	#make & configure gridmap
	var gmap_cell_size = 1
	var gmap_scale = 1

	var gmap = GridMap.new()
	gmap.mesh_library = tiles
	gmap.cell_center_x = false
	gmap.cell_center_y = false
	gmap.cell_center_z = false
	gmap.cell_size = Vector3(gmap_cell_size,gmap_cell_size,gmap_cell_size)
	gmap.cell_scale = gmap_scale
	gmap.cell_octant_size = 2048
	gmap.name = "DetailMap"

	room_geometry.add_child(gmap)
	gmap.owner = room_geometry.owner

	configure_surface_type(gmap)

	return gmap
