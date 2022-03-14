extends Node
class_name RoomsDataGenerator

var _rng
var _enemy_difficulty
var _enemy_difficulty_variation
var _room_min_walls_length
var _room_max_walls_length
var _room_min_walls_height
var _room_max_walls_height
var _sub_path_length
var _prefab_rooms
var _prefabs_on_main

enum SUB_PATH_PURPOSE{
	KEY,
	#WEAPON,
	TREASURE,
	KEY_AND_TREASURE
	#TRAPPED_TREASURE
}

const EXTRA_CONTENTS_NULL_ID = -1
const LOCKED_DOOR_EXTRA_CONTENTS_ID = 127
const EXIT_DOOR_EXTRA_CONTENTS_ID = 126

func _init(var rng : RandomNumberGenerator,
		var enemy_difficulty: float,
		var enemy_difficulty_variation: float,
		var room_min_walls_length: int,
		var room_max_walls_length: int,
		var room_min_walls_height: int,
		var room_max_walls_height: int,
		var sub_path_length: int,
		var prefab_rooms: Array,
		var prefabs_on_main: bool):

	_rng = rng
	_enemy_difficulty = enemy_difficulty
	_enemy_difficulty_variation = enemy_difficulty_variation
	_room_min_walls_length = room_min_walls_length
	_room_max_walls_length = room_max_walls_length
	_room_min_walls_height = room_min_walls_height
	_room_max_walls_height = room_max_walls_height
	_sub_path_length = sub_path_length
	_prefab_rooms = prefab_rooms
	_prefabs_on_main = prefabs_on_main

func generate_difficulty_pools(var number_of_rooms: int):
	var difficulty_pool = []
	difficulty_pool.resize(number_of_rooms)

	var available_pool_indexes = []
	available_pool_indexes.resize(number_of_rooms)
	for i in range(0, number_of_rooms):
		available_pool_indexes[i] = i

	while not available_pool_indexes.empty():
		var desired_difficulty = _rng.randf_range(_enemy_difficulty-_enemy_difficulty_variation, _enemy_difficulty+_enemy_difficulty_variation)

		var index_a = available_pool_indexes[_rng.randi()%available_pool_indexes.size()-1]

		difficulty_pool[index_a] = desired_difficulty
		available_pool_indexes.erase(index_a)

		var opposite_difficulty = _enemy_difficulty+(_enemy_difficulty-desired_difficulty)

		if available_pool_indexes.size() > 0:
			var index_b = available_pool_indexes[_rng.randi()%available_pool_indexes.size()-1]
			difficulty_pool[index_b] = opposite_difficulty
			available_pool_indexes.erase(index_b)

	return difficulty_pool

func generate_room_sizes(var number_of_rooms: int, var prefab_rooms: Array):
	var ret = []
	for i in range(0, number_of_rooms):
		if prefab_rooms[i]:
			var room = prefab_rooms[i]["ref"].instance()
			var cells = room.get_used_cells()
			var max_x = 0
			var max_y = 0
			var max_z = 0
			for c in cells:
				if c.x > max_x:
					max_x = c.x
				if c.y+3 > max_y:
					max_y = c.y+3
				if c.z > max_z:
					max_z = c.z
			ret.push_back(Vector3(max_x, max_y, max_z))
#			room.queue_free() ??
		else:
			ret.push_back(Vector3(
				_rng.randi_range(_room_min_walls_length, _room_max_walls_length),
				_rng.randi_range(_room_min_walls_height, _room_max_walls_height),
				_rng.randi_range(_room_min_walls_length, _room_max_walls_length)))

	return ret

func add_to_tree(var new_node, var node_name: String, var parent: Node):
	new_node.name = node_name
	parent.add_child(new_node)
	new_node.set_owner(owner)

func add_next_room_node(var room_name: String, var parent: Node,
	var size: Vector3, var difficulties: Array, var prefab_rooms: Array,
	var index: int, var purpose: int):

	var new_room = GeneratedRoom.new()
	add_to_tree(new_room, room_name, parent)

	new_room.size = size
	new_room.difficulty = difficulties[index]
	if prefab_rooms[index]:
		new_room.prefab_room = prefab_rooms[index]["ref"]

	match purpose:
		SUB_PATH_PURPOSE.KEY:
			new_room.traits.append(GeneratedRoom.ROOM_TRAITS.KEY)
		SUB_PATH_PURPOSE.TREASURE:
			new_room.traits.append(GeneratedRoom.ROOM_TRAITS.TREASURE)
		SUB_PATH_PURPOSE.KEY_AND_TREASURE:
			new_room.traits.append(GeneratedRoom.ROOM_TRAITS.KEY_AND_TREASURE)
		LOCKED_DOOR_EXTRA_CONTENTS_ID:
			new_room.traits.append(GeneratedRoom.ROOM_TRAITS.LOCKED_DOOR)
		EXIT_DOOR_EXTRA_CONTENTS_ID:
			new_room.traits.append(GeneratedRoom.ROOM_TRAITS.EXIT_DOOR)

	return new_room

func add_root_node(var room_name: String, var parent: Node):
	var map_root = Spatial.new()
	add_to_tree(map_root, room_name, parent)

	return map_root

func decide_upon_prefab_rooms(var max_total_rooms: int):
	var prefab_room_locations = []
	prefab_room_locations.resize(max_total_rooms)

	if _prefab_rooms.empty():
		return prefab_room_locations

	#find possible indexes to place rooms by
	#use only odd numbers, because
	#1. only "pure" generated rooms in between guarante entrance-exit connections (for now)
	#2. if prefab rooms are allowed in sub_paths, we can't have one as first room (connection problem again)
	var available = []
	for i in range(0, int(float(max_total_rooms-1)/2)):
		available.push_back(2 * i + 1)

	#randomly pick without repetitions
	for r in _prefab_rooms:
		if available.size() >= 1:
			var new_index = available[_rng.randi()%available.size()]
			prefab_room_locations[new_index] = r
			available.erase(new_index)

	return prefab_room_locations

func generate_design_tree(var main_path_length: int, var num_of_sub_paths: int):
	#make new subtree under parent
	var current_room = owner
	current_room = add_root_node("generated_map", current_room)
	var generated_tree_root = current_room

	#starting room
	var new_room = GeneratedRoom.new()
	new_room.size = Vector3(4, 3, 4)
	new_room.difficulty = 0
	new_room.traits.push_back(GeneratedRoom.ROOM_TRAITS.STARTING)
	new_room.traits.push_back(GeneratedRoom.ROOM_TRAITS.MAIN)
	add_to_tree(new_room, "starting_room", current_room)
	current_room = new_room

	generate_path(current_room, main_path_length, EXIT_DOOR_EXTRA_CONTENTS_ID)

	if num_of_sub_paths != 0 and _sub_path_length < 1:
		print("Can't generate sub-paths if their max length is 0")
		return generated_tree_root

	#generate_sub_paths
	for _i in range(0, num_of_sub_paths):
		#collect all GeneratedRoom children

		var all_rooms = []
		collect_children(current_room, all_rooms)
		var filtered_rooms = []
		#filter out these without available exits
		for j in range(0, all_rooms.size()):
			#find number of available exits
			var exits_left = 0
			if not all_rooms[j].prefab_room:
				#this is purely generated room,
				#can have up to 1 entrance and 3 exits
				exits_left = 3 - all_rooms[j].get_child_count()
			else:
				#this is prefab room
				#need to check it's gridmap
				var gmap = all_rooms[j].prefab_room.instance() as GridMap
				var cells = gmap.get_used_cells()

				var exit_cell_ids = [5,6,7,8]
				for id in exit_cell_ids:
					for cell in cells:
						if gmap.get_cell_item(cell.x, cell.y, cell.z) == id:
							exits_left += 1
							break

				#one exit was used for entrance already (parent)
				exits_left -= 1

				#rest is for children but some may exist already
				exits_left = exits_left - all_rooms[j].get_child_count()

			if (exits_left > 0 and (not all_rooms[j].traits.has(GeneratedRoom.ROOM_TRAITS.EXIT_DOOR))):
				filtered_rooms.push_back(all_rooms[j])

		if filtered_rooms.empty():
			print("Warning: No more valid rooms to make sub path from")
			break;

		var sub_path_root = filtered_rooms[_rng.randi() % filtered_rooms.size()]
		var path_purpose = _rng.randi() % SUB_PATH_PURPOSE.size()
		if (sub_path_root.get_child_count() != 0
			and not sub_path_root.get_child(0).traits.has(GeneratedRoom.ROOM_TRAITS.LOCKED_DOOR)
			and (path_purpose == SUB_PATH_PURPOSE.KEY or path_purpose == SUB_PATH_PURPOSE.KEY_AND_TREASURE)):
				#but do we always need player to spend the key? no, let them keep it sometimes
				if _rng.randi()%100 < 80:
					sub_path_root.get_child(0).traits.append(GeneratedRoom.ROOM_TRAITS.LOCKED_DOOR)
		else:
			#if we can't make locked door for key to unlock, we change purpose to something else
			path_purpose = SUB_PATH_PURPOSE.TREASURE

		# let's try to not have each and every sub path on the map the same length
		var new_sub_path_length = _rng.randi_range(1, _sub_path_length)

		generate_path(sub_path_root, new_sub_path_length, path_purpose)

	return generated_tree_root

func collect_children(var room: GeneratedRoom, var collection: Array):
	var children = room.get_children()
	for c in children:
		collection.append(c)
		collect_children(c, collection)

func generate_path(var path_root: Node, var number_of_rooms: int, var purpose: int):
	#plan room sizes
	var prefab_room_locations
	if _prefabs_on_main:
		if purpose == EXIT_DOOR_EXTRA_CONTENTS_ID:
			#only place prefab rooms on main path
			prefab_room_locations = decide_upon_prefab_rooms(number_of_rooms)
		else:
			#if this is not main path, just make empty array
			prefab_room_locations = []
			prefab_room_locations.resize(number_of_rooms)
	else:
		#place prefab rooms anywhere in map
		#their floor tile may be misleading -> todo: fix them upon spawning?
		prefab_room_locations = decide_upon_prefab_rooms(number_of_rooms)

	var generated_sizes = generate_room_sizes(number_of_rooms, prefab_room_locations)
	var generated_difficulties = generate_difficulty_pools(number_of_rooms)

	var current_room = path_root

	for i in range(0, number_of_rooms):
		if i == number_of_rooms-1: #last room
			current_room = add_next_room_node("end_room", current_room,
			generated_sizes[i], generated_difficulties, prefab_room_locations, i, purpose)
			if purpose == EXIT_DOOR_EXTRA_CONTENTS_ID:
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.END_MAIN)
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.ARENA)
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.MAIN)
			else:
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.END_SUB)
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.SUB)
				if _rng.randi()%2 == 0:
					current_room.traits.append(GeneratedRoom.ROOM_TRAITS.ARENA)
				else:
					current_room.traits.append(GeneratedRoom.ROOM_TRAITS.NORMAL_CORRIDORS)
		else:
			current_room = add_next_room_node("normal_room", current_room,
			generated_sizes[i], generated_difficulties, prefab_room_locations, i, EXTRA_CONTENTS_NULL_ID)
			current_room.traits.append(GeneratedRoom.ROOM_TRAITS.NORMAL_CORRIDORS)
			if purpose == EXIT_DOOR_EXTRA_CONTENTS_ID:
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.MAIN)
			else:
				current_room.traits.append(GeneratedRoom.ROOM_TRAITS.SUB)

