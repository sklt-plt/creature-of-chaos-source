extends Node
class_name RandomWalksInteriorGenerator

var _owner
var _rng
var _tiles
var _main_paths_width_table
var _other_paths_width_table
var _num_of_random_paths

const DEBUG = 0

const DEF_NUM_OF_RANDOM_PATHS = 15

const PATH_WIDTH_TINY = 1
const PATH_WIDTH_SMALL = 2
const PATH_WIDTH_MEDIUM = 3
const PATH_WIDTH_BIG = 4
const PATH_WIDTH_LARGE = 5

const PATH_WIDTH_MAINS = [
	PATH_WIDTH_TINY,
	PATH_WIDTH_SMALL]

enum PATH_WIDTHS_OTHERS {
	PATH_WIDTHS_OTHERS_DEFAULT,
	PATH_WIDTHS_OTHERS_SMALL,
	PATH_WIDTHS_OTHERS_MEDIUM,
	PATH_WIDTHS_OTHERS_LARGE,
	PATH_WIDTHS_OTHERS_RANDOM}

const PATH_WIDTHS_OTHERS_DEFAULT = [
	PATH_WIDTH_TINY,
	PATH_WIDTH_SMALL, PATH_WIDTH_SMALL, PATH_WIDTH_SMALL,PATH_WIDTH_SMALL, PATH_WIDTH_SMALL, PATH_WIDTH_SMALL,
	PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM,
	PATH_WIDTH_BIG, PATH_WIDTH_BIG, PATH_WIDTH_BIG, PATH_WIDTH_BIG, PATH_WIDTH_BIG,
	PATH_WIDTH_LARGE]

const PATH_WIDTHS_OTHERS_SMALL = [
	PATH_WIDTH_TINY, PATH_WIDTH_TINY, PATH_WIDTH_TINY, PATH_WIDTH_TINY,
	PATH_WIDTH_SMALL, PATH_WIDTH_SMALL]

const PATH_WIDTHS_OTHERS_MEDIUM = [
	PATH_WIDTH_SMALL, PATH_WIDTH_SMALL,
	PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM, PATH_WIDTH_MEDIUM]

const PATH_WIDTHS_OTHERS_LARGE = [
	PATH_WIDTH_BIG, PATH_WIDTH_BIG, PATH_WIDTH_BIG, PATH_WIDTH_BIG,
	PATH_WIDTH_LARGE, PATH_WIDTH_LARGE]

const PATH_WIDTHS_OTHERS_RANDOM = [
	PATH_WIDTH_TINY,
	PATH_WIDTH_SMALL,
	PATH_WIDTH_MEDIUM,
	PATH_WIDTH_BIG,
	PATH_WIDTH_LARGE]

const PATH_WIDTHS_TABLES = [PATH_WIDTHS_OTHERS_DEFAULT,
	PATH_WIDTHS_OTHERS_SMALL,
	PATH_WIDTHS_OTHERS_MEDIUM,
	PATH_WIDTHS_OTHERS_LARGE,
	PATH_WIDTHS_OTHERS_RANDOM]

var _current_bounds

func _init(var owner: Node, var tiles: String,
	var rng: RandomNumberGenerator,
	var other_paths_width_table = PATH_WIDTHS_TABLES[PATH_WIDTHS_OTHERS.PATH_WIDTHS_OTHERS_DEFAULT],
	#var main_paths_width_table = PATH_WIDTH_MAINS,
	var num_of_random_paths = DEF_NUM_OF_RANDOM_PATHS):

		_owner = owner
		_tiles = load(Globals.content_pack_path + tiles)
		_rng = rng
		_other_paths_width_table = PATH_WIDTHS_TABLES[other_paths_width_table]
		_main_paths_width_table = PATH_WIDTH_MAINS
		_num_of_random_paths = num_of_random_paths

func generate(var room_geometry : RoomGeometry):
	var gmap = GridMapHelper.configure_gridmap(room_geometry, _tiles)
	place_paths(room_geometry, gmap)

func place_paths(var room_geometry: RoomGeometry, var gmap: GridMap):
	var links = room_geometry.used_exits()


	place_reserved_tiles_at_links(links, gmap)
	_current_bounds = room_geometry.size

	var is_main_path_room = get_node(room_geometry.tree_ref).traits.has(GeneratedRoom.ROOM_TRAITS.MAIN)
	var junctions = make_path_connecting_exits(links, gmap, is_main_path_room)
	make_aditional_random_paths(junctions, room_geometry, gmap)
	TilesOutlineHelper.make_tile_outiline([GeneratorConstants.TILE_RESERVED_PATH_ID, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID],
		GeneratorConstants.TILE_OBSTACLE_ID, GeneratorConstants.TILE_ITEM_ID, gmap)

func place_reserved_tiles_at_links(var links, var gmap):
	for l in links:
		if l["direction"] < 2:
			for x in range(l["origin"].x, l["origin"].x+l["size"].x+1):
				gmap.set_cell_item(x, 0, l["origin"].z, GeneratorConstants.TILE_RESERVED_ACCESSIBLE_ID)
		else:
			for y in range(l["origin"].z, l["origin"].z+l["size"].x+1): # WHY SIZE IS Vec2????
				gmap.set_cell_item(l["origin"].x, 0, y, GeneratorConstants.TILE_RESERVED_ACCESSIBLE_ID)

func make_aditional_random_paths(var junctions: Array, var room_geometry: RoomGeometry, var gmap: GridMap):
	var bonus_width = _other_paths_width_table[_rng.randi()%(_other_paths_width_table.size())]
	var clear_awnings = bool(_rng.randi()%2)

	for _i in range(0, _num_of_random_paths):
		#select height
		var walls_heigth = _current_bounds.y - _rng.randi()%2 #so it's smaller or equal to main paths

		#take random existing turn
		var begginig_junction = junctions[_rng.randi()%junctions.size()]
		#make new turn between it and different connected turn or go in a new direction
		#take a directions
		var possible_dirs = find_possible_directions(begginig_junction["origin"], room_geometry)
		var desired_dir = possible_dirs[_rng.randi()%possible_dirs.size()]

		if begginig_junction["connecting_dirs"].has(desired_dir):
			#subdivide that dir
			var other_end_ind = begginig_junction["connecting_dirs"].find(desired_dir)
			var other_end = begginig_junction["connects"][other_end_ind]

			#make subdivision turn
			var sub_origin = Vector3((begginig_junction["origin"].x+other_end["origin"].x)/2,
				(begginig_junction["origin"].y+other_end["origin"].y)/2,
				(begginig_junction["origin"].z+other_end["origin"].z)/2)

			var sub_junction = {"origin": sub_origin, "connects": [begginig_junction, other_end],
				"connecting_dirs":
				[find_which_direction_this_is(sub_origin, begginig_junction["origin"]),
				find_which_direction_this_is(sub_origin, other_end["origin"])],
				"widths":
				[begginig_junction["widths"][other_end_ind],
				begginig_junction["widths"][other_end_ind]]}


			#update neighbours
			begginig_junction["connects"][other_end_ind] = sub_junction
			if other_end.has("connects"):
				var this_junctions_id_in_other_end = other_end["connects"].find(begginig_junction)
				other_end["connects"][this_junctions_id_in_other_end] = sub_junction

			#extrude new_junction from sub_junction
			#pick perpendicular direction and possible lenght
			var new_possible_dirs = find_perpendicular_dirs(desired_dir)
			var new_dir = new_possible_dirs[_rng.randi()%new_possible_dirs.size()]
			var new_junction = make_new_junction(sub_junction, new_dir, room_geometry)
			new_junction["widths"].append(bonus_width)

			#subdivision connects new, too
			sub_junction["connects"].append(new_junction)
			sub_junction["connecting_dirs"].append(find_which_direction_this_is(sub_origin, new_junction["origin"]))
			sub_junction["widths"].append(bonus_width)

			junctions.append(sub_junction)
			junctions.append(new_junction)

			#maybe connect those two
			make_rectangular_path_piece(sub_origin, new_junction["origin"],
				gmap, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID, bonus_width, bonus_width, walls_heigth, 0, clear_awnings)

		else:
			var new_junction = make_new_junction(begginig_junction, desired_dir, room_geometry)
			new_junction["widths"].append(bonus_width)
			junctions.append(new_junction)

			#maybe connect those two
			make_rectangular_path_piece(begginig_junction["origin"], new_junction["origin"],
				gmap, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID, bonus_width, bonus_width, walls_heigth, 0, clear_awnings)

func make_new_junction(var from: Dictionary, var direction: int, var room_geometry: RoomGeometry):
	var new_junction_origin = find_new_junction_origin(from["origin"], direction, room_geometry)
	var opposite_dir = find_opposite_dir(direction)
	return{"origin": new_junction_origin, "connects": [from], "connecting_dirs": [opposite_dir], "widths": []}

func find_new_junction_origin(var previous_origin: Vector3, var new_dir: int, var room_geometry: RoomGeometry):
	match [new_dir]:
		[0]:
			#go north
			var length = _rng.randi_range(1, previous_origin.z)
			return Vector3(previous_origin.x, previous_origin.y, previous_origin.z-length)
		[1]:
			#go south
			var length = _rng.randi_range(1, room_geometry.size.z-previous_origin.z)
			return Vector3(previous_origin.x, previous_origin.y, previous_origin.z+length)
		[2]:
			#go east
			var length = _rng.randi_range(1, room_geometry.size.x-previous_origin.x)
			return Vector3(previous_origin.x+length, previous_origin.y, previous_origin.z)
		[3]:
			#go west
			var length = _rng.randi_range(1, previous_origin.x)
			return Vector3(previous_origin.x-length, previous_origin.y, previous_origin.z)

func find_opposite_dir(var dir: int):
	match [dir]:
		[0]:
			return 1
		[1]:
			return 0
		[2]:
			return 3
		[3]:
			return 2

func find_perpendicular_dirs(var beggining_dir: int):
	if beggining_dir == 0 || beggining_dir == 1:
		return [2,3]
	else:
		return [0,1]

func find_which_direction_this_is(var a: Vector3, var b: Vector3):
	if a.x == b.x:
		if a.z < b.z:
			#path goes south
			return 1
		else:
			#path goes north
			return 0
	elif a.z == b.z:
		if a.x > b.x:
			#path goes west
			return 2
		else:
			#path goes east
			return 3

func make_path_connecting_exits(var links: Array, var gmap: GridMap, var main_path_room: bool):
	var bonus_size = _main_paths_width_table[_rng.randi()%_main_paths_width_table.size()]
	var walls_heigth = _current_bounds.y #full for room height which is already random
	var junctions = []
	var tile_path_id = GeneratorConstants.TILE_RESERVED_PATH_ID if main_path_room else GeneratorConstants.TILE_RESERVED_SUB_PATH_ID

	#find midway point (doesn't have to be literal)
	var mid = {"origin": Vector3(0,0,0), "connects": [], "connecting_dirs": [], "widths": []}

	if (links.size() == 2 and ((links[0]["direction"] <= 1 and links[1]["direction"] >= 2)
		or (links[0]["direction"] >= 2 and links[1]["direction"] <= 1))):
		#this is case of exits on connected walls - ((north or south) and (east or west))
		if links[0]["direction"] <= 1: # link 0 is north or south and link 1 is west or east
			mid["origin"].x = links[0]["origin"].x
			mid["origin"].z = links[1]["origin"].z
		else:
			mid["origin"].x = links[1]["origin"].x
			mid["origin"].z = links[0]["origin"].z

		mid["connects"] = [{"origin": links[0]["origin"]}, {"origin": links[1]["origin"]}]
		mid["connecting_dirs"].append(find_which_direction_this_is(mid["origin"], links[0]["origin"]))
		mid["connecting_dirs"].append(find_which_direction_this_is(mid["origin"], links[1]["origin"]))
		mid["widths"].append(bonus_size)
		mid["widths"].append(bonus_size)

		#special case - if any link is west or north then we need to overdraw a little
		if links[0]["direction"] == 2 or links[0]["direction"] == 0 or links[1]["direction"] == 2 or links[1]["direction"] == 0:
			make_rectangular_path_piece(links[0]["origin"], mid["origin"],
				gmap, tile_path_id, bonus_size, links[0]["size"].x+bonus_size, walls_heigth, bonus_size+1)
			make_rectangular_path_piece(links[1]["origin"], mid["origin"],
				gmap, tile_path_id, bonus_size, links[1]["size"].x+bonus_size, walls_heigth, bonus_size+1)
		else:
			make_rectangular_path_piece(links[0]["origin"], mid["origin"],
				gmap, tile_path_id, bonus_size, links[0]["size"].x+bonus_size, walls_heigth)
			make_rectangular_path_piece(links[1]["origin"], mid["origin"],
				gmap, tile_path_id, bonus_size, links[1]["size"].x+bonus_size, walls_heigth)

	else:
		#exits on opposite walls or more than 2 exits
		#midpoint is geometrical
		for l in links:
			mid["origin"].x += l["origin"].x
			mid["origin"].z += l["origin"].z

		mid["origin"].x = mid["origin"].x/links.size()
		mid["origin"].z = mid["origin"].z/links.size()

		#connect each entrance to midway point (2-steps)
		for l in links:
			#unless we're in sub room,
			#more than 2 link imply that at least one leads to sub path
			#so we should pick ensure correct floor tile for next path piece
			if main_path_room:
				if get_node(get_node(l["target"]).tree_ref).traits.has(GeneratedRoom.ROOM_TRAITS.MAIN):
					tile_path_id = GeneratorConstants.TILE_RESERVED_PATH_ID
				else:
					tile_path_id = GeneratorConstants.TILE_RESERVED_SUB_PATH_ID

			var mid_mid = {"origin": Vector3(0,0,0), "connects": [], "connecting_dirs": [], "widths": []}
			if l["direction"] == 2 or l["direction"] == 3:
				mid_mid["origin"].x = mid["origin"].x
				mid_mid["origin"].z = l["origin"].z
			else:
				mid_mid["origin"].x = l["origin"].x
				mid_mid["origin"].z = mid["origin"].z

			mid_mid["connects"] = [{"origin": l["origin"]}, mid]
			mid_mid["connecting_dirs"].append(find_which_direction_this_is(mid_mid["origin"], l["origin"]))
			mid_mid["connecting_dirs"].append(find_which_direction_this_is(mid_mid["origin"], mid["origin"]))
			mid_mid["widths"].append(bonus_size)
			mid_mid["widths"].append(bonus_size)
			mid["connects"].append(mid_mid)
			mid["connecting_dirs"].append(find_which_direction_this_is(mid["origin"], mid_mid["origin"]))
			mid["widths"].append(bonus_size)

			#special case 1 - if either link or mid is west or north then we need overdraw
			if (l["origin"].x <= mid_mid["origin"].x or l["origin"].z <= mid_mid["origin"].z
				or mid["origin"].x <= mid_mid["origin"].x or mid["origin"].z <= mid_mid["origin"].z):
					make_rectangular_path_piece(l["origin"], mid_mid["origin"],
						gmap, tile_path_id, bonus_size, l["size"].x+bonus_size, walls_heigth, bonus_size+1)
					make_rectangular_path_piece(mid_mid["origin"], mid["origin"],
						gmap, tile_path_id, bonus_size, l["size"].x+bonus_size, walls_heigth, bonus_size+1)
			else:
				make_rectangular_path_piece(l["origin"], mid_mid["origin"],
					gmap, tile_path_id, bonus_size, l["size"].x+bonus_size, walls_heigth)
				make_rectangular_path_piece(mid_mid["origin"], mid["origin"],
					gmap, tile_path_id, bonus_size, l["size"].x+bonus_size, walls_heigth)

			junctions.push_back(mid_mid)

	junctions.push_back(mid)
	return junctions

func find_possible_directions(var begginig_junction: Vector3, var room_geometry: RoomGeometry):
	var dirs = [0,1,2,3]
	if begginig_junction.z == 0:
		dirs.erase(0)
	if begginig_junction.z == room_geometry.size.z:
		dirs.erase(1)
	if begginig_junction.x == room_geometry.size.x:
		dirs.erase(2)
	if begginig_junction.x == 0:
		dirs.erase(3)
	return dirs

func is_wall_tile_in_bounds(var point: Vector3):
	if point.x < 0 or point.y < 0 or point.z < 0:
		return false
	elif point.x > _current_bounds.x or point.y > _current_bounds.y or point.z > _current_bounds.z:
		return false
	else:
		return true

func is_floor_tile_in_bounds(var point: Vector3):
	if point.x < 1 or point.y < 0 or point.z < 1:
		return false
	elif point.x > _current_bounds.x-1 or point.y > _current_bounds.y or point.z > _current_bounds.z-1:
		return false
	else:
		return true

func make_rectangular_path_piece(var point_a: Vector3, var point_b: Vector3, var gmap: GridMap, var reserved_path_tile : int,
	var thickness_left = 0, var thickness_right = 0, var wall_height = 1, var overdraw = 0, var clear_awnings = false):

	var x1 = point_a.x
	var x2 = point_b.x
	if point_b.x < point_a.x:
		x1 = point_b.x
		x2 = point_a.x

	var z1 = point_a.z
	var z2 = point_b.z
	if point_b.z < point_a.z:
		z1 = point_b.z
		z2 = point_a.z

	#find direction to add thickness
	if x1 == x2:
		#vertical line
		x1 -= thickness_left
		x2 += thickness_right
		z2 += overdraw
	else:
		#horizontal line
		z1 -= thickness_left
		z2 += thickness_right
		x2 += overdraw

	var real_x1 = -6900 # custom int NAN
	var real_x2 = -6900
	var real_z1 = -6900
	var real_z2 = -6900

	#find real corners
	for x in range(x1-1, x2+2):
		for z in range(z1-1, z2+2):
			if is_wall_tile_in_bounds(Vector3(x,0,z)):
				if real_x1 == -6900:
					real_x1 = x
				else:
					real_x2 = x
				if real_z1 == -6900:
					real_z1 = z
				else:
					real_z2 = z

	#draw reserved path
	for x in range(real_x1, real_x2+1):
		for z in range(real_z1, real_z2+1):
			if (is_floor_tile_in_bounds(Vector3(x, 0, z))
				and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_PATH_ID):
				#and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_SUB_PATH_ID):
				#set tile
				gmap.set_cell_item(x, 0, z, reserved_path_tile)
				#override possible existing walls from previous path pieces
				var desired_height = wall_height
				if clear_awnings:
					desired_height = _current_bounds.y+1
				for h in range(1, desired_height):
					gmap.set_cell_item(x, h, z, GridMap.INVALID_CELL_ITEM)

			elif (is_wall_tile_in_bounds(Vector3(x, 0, z))
				and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_PATH_ID
				and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_SUB_PATH_ID):
				#set tile
				gmap.set_cell_item(x, 0, z, GeneratorConstants.TILE_RESERVED_ACCESSIBLE_ID)
				#override possible existing walls from previous path pieces
				var desired_height = wall_height
				if clear_awnings:
					desired_height = _current_bounds.y+1
				for h in range(1, desired_height):
					gmap.set_cell_item(x, h, z, GridMap.INVALID_CELL_ITEM)

	for x in range(real_x1-1, real_x2+2):
		for z in range(real_z1-1, real_z2+2):
			if (is_wall_tile_in_bounds(Vector3(x, 0, z))
				and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_PATH_ID
				and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_SUB_PATH_ID
				and gmap.get_cell_item(x, 0, z) != GeneratorConstants.TILE_RESERVED_ACCESSIBLE_ID):

				for h in range(0, wall_height+1):
					gmap.set_cell_item(x, h, z, GeneratorConstants.TILE_OBSTACLE_ID)

