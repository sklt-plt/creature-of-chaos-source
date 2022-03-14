extends Node
class_name ArenaGenerator

var _owner
var _rng
var _tiles
var _symmetry
var _obstacles_per_quadrant
var _obstacle_outline
var _min_obstacle_length
var _max_obstacle_length

const OBSTACLE_ROOM_MARGIN = 2
const OUTLINE_ROOM_MARGIN = 1

const patterns = ["rect", "lineH", "lineV"]#, "empty"]

func _init(var owner: Node, var tiles: String, var rng: RandomNumberGenerator, var symmetry: bool, var obstacles_per_quadrant: int, var obstacle_outline: int, var min_obstacle_length: int, var max_obstacle_length: int):
	_owner = owner
	_tiles = load(Globals.content_pack_path + tiles)
	_rng = rng
	_symmetry = symmetry
	_obstacles_per_quadrant = obstacles_per_quadrant
	_obstacle_outline = obstacle_outline
	_min_obstacle_length = min_obstacle_length
	_max_obstacle_length = max_obstacle_length

func generate(var room_geometry : RoomGeometry):
	var gmap = GridMapHelper.configure_gridmap(room_geometry, _tiles)

	var is_main_path_room = get_node(room_geometry.tree_ref).traits.has(GeneratedRoom.ROOM_TRAITS.MAIN)

	place_obstacles(room_geometry, gmap, is_main_path_room)

	TilesOutlineHelper.make_tile_outiline([GeneratorConstants.TILE_RESERVED_PATH_ID, GeneratorConstants.TILE_RESERVED_SUB_PATH_ID],
		GeneratorConstants.TILE_OBSTACLE_ID, GeneratorConstants.TILE_ITEM_ID, gmap)

func find_room_quadrants(var room_geometry: RoomGeometry):
	var ret = {}
	#first
	var q1b = Vector2(OBSTACLE_ROOM_MARGIN, OBSTACLE_ROOM_MARGIN)
	var q1e = Vector2(room_geometry.size.x/2, room_geometry.size.z/2)
	ret["q1b"] = q1b
	ret["q1e"] = q1e
	#second
	var q2b = Vector2((room_geometry.size.x/2), OBSTACLE_ROOM_MARGIN)
	var q2e = Vector2(room_geometry.size.x-OBSTACLE_ROOM_MARGIN, room_geometry.size.z/2)
	ret["q2b"] = q2b
	ret["q2e"] = q2e
	#third
	var q3b = Vector2(OBSTACLE_ROOM_MARGIN, (room_geometry.size.z/2))
	var q3e = Vector2(room_geometry.size.x/2, room_geometry.size.z-OBSTACLE_ROOM_MARGIN)
	ret["q3b"] = q3b
	ret["q3e"] = q3e
	#fourth
	var q4b = Vector2((room_geometry.size.x/2), (room_geometry.size.z/2))
	var q4e = Vector2(room_geometry.size.x-OBSTACLE_ROOM_MARGIN, room_geometry.size.z-OBSTACLE_ROOM_MARGIN)
	ret["q4b"] = q4b
	ret["q4e"] = q4e

	return ret

func get_quadrant_begin_end_vectors(var quads: Dictionary, var index: int):
	match index:
		0: return [quads["q1b"], quads["q1e"]]
		1: return [quads["q2b"], quads["q2e"]]
		2: return [quads["q3b"], quads["q3e"]]
		3: return [quads["q4b"], quads["q4e"]]


func place_obstacles(var room_geometry: RoomGeometry, var gmap: GridMap, var main_path_room: bool):
	var quadrants = find_room_quadrants(room_geometry)

	for current_quadrant in range(0,4):
		var qbegin = get_quadrant_begin_end_vectors(quadrants, current_quadrant)[0]
		var qend = get_quadrant_begin_end_vectors(quadrants, current_quadrant)[1]

		for _j in range(0, _obstacles_per_quadrant):
			var begin = Vector2(_rng.randi_range(qbegin.x, qend.x), _rng.randi_range(qbegin.y, qend.y))

			#pick a pattern
			var selected_pattern = _rng.randi()%patterns.size()
			var pattern_height = _rng.randi()%3
			match (pattern_height):
				0:
					pattern_height = 1
				1:
					pattern_height = room_geometry.size.y - 1
				2:
					pattern_height = room_geometry.size.y

			#lines & rectangle
			var direction
			match (selected_pattern):
				0:
					#is rectangular obstacle
					direction = Vector2(_rng.randi_range(_min_obstacle_length, _max_obstacle_length), _rng.randi_range(_min_obstacle_length, _max_obstacle_length))
				1:
					#is horizontal line
					direction = Vector2(_rng.randi_range(_min_obstacle_length, _max_obstacle_length), 1)
				2:
					#is vert line
					direction = Vector2(1, _rng.randi_range(_min_obstacle_length, _max_obstacle_length))
				3:
					#is free area
					direction = Vector2(_rng.randi_range(_min_obstacle_length, _max_obstacle_length), _rng.randi_range(_min_obstacle_length, _max_obstacle_length))

			var end = begin + direction
			end.x = clamp(end.x, 0, qend.x)
			end.y = clamp(end.y, 0, qend.y)

			var floor_tile = GeneratorConstants.TILE_RESERVED_PATH_ID if main_path_room else GeneratorConstants.TILE_RESERVED_SUB_PATH_ID

			if selected_pattern < 3:
				place_rectangular_obstacle(begin, end, pattern_height, gmap, GeneratorConstants.TILE_OBSTACLE_ID)
				place_outline(begin, end, gmap, room_geometry)
			else:
				place_rectangular_obstacle(begin, direction, 1, gmap, floor_tile)

		current_quadrant += 1
		current_quadrant = current_quadrant%4

func place_rectangular_obstacle(var begin: Vector2, var end: Vector2, var height: int, var gmap: GridMap, var tile_id: int):
	for x in range(begin.x, end.x):
		for y in range(begin.y, end.y):
			if gmap.get_cell_item(x,0,y) == GridMap.INVALID_CELL_ITEM:
				for h in range (0, height):
					gmap.set_cell_item(x, h, y, tile_id)


func place_outline(var begin: Vector2, var end: Vector2, var gmap: GridMap, room_geometry: RoomGeometry):
	var is_main_path_room = get_node(room_geometry.tree_ref).traits.has(GeneratedRoom.ROOM_TRAITS.MAIN)
	var floor_tile = GeneratorConstants.TILE_RESERVED_PATH_ID if is_main_path_room else GeneratorConstants.TILE_RESERVED_SUB_PATH_ID

	for x in range(begin.x-_obstacle_outline, end.x+_obstacle_outline):
		for y in range(begin.y-_obstacle_outline, end.y+_obstacle_outline):
			if x < OUTLINE_ROOM_MARGIN || x > room_geometry.size.x-OUTLINE_ROOM_MARGIN || y < OUTLINE_ROOM_MARGIN || y > room_geometry.size.z-OUTLINE_ROOM_MARGIN:
				continue
			if gmap.get_cell_item(x, 0, y) != GeneratorConstants.TILE_OBSTACLE_ID:
				gmap.set_cell_item(x, 0, y, floor_tile)
			if gmap.get_cell_item(x, 0, y) != GeneratorConstants.TILE_OBSTACLE_ID:
				gmap.set_cell_item(x, 0, y, floor_tile)
