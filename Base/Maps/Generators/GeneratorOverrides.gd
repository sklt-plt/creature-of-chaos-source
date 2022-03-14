extends Node
class_name GeneratorOverrides

var done = false

var gen_seed = ""
var make_ceilings = false
#export (bool) var links_on_floor = true

var main_path_length = 3
var sub_path_max_length = 3
var num_of_sub_paths = 3

var min_room_size = 15
var max_room_size = 15
var min_room_height = 3
var max_room_height = 4

var _average_room_difficulty = 0.0
var _average_difficulty_variation = 0

var _max_random_walks = 15
var _random_walks_widths

var _arena_obstacle_per_quadrant = 2
var _arena_obstacle_outline_thickness = 2
var _arena_obstacle_min_size = 1
var _arena_obstacle_max_size = 5

var use_prefabs = true
var _prefabs_on_main = true

const BASE_ROOM_SIZE = 15
const MAX_MAIN_PATH_ROOMS = 15

func _ready():
	var ui_node = get_node_or_null("OverridesUI")
	if ui_node:
		#player will set values and "done" through ui
		return
	else:
		#randomize overrides and set "done"
		randomize_values()
		done = true

func randomize_values():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	gen_seed = ""	# will be randomized by Generator

	var desired_difficulty = float($"/root/Player".check("s_level"))*1.5

	var total_safe_max_rooms = 15
	num_of_sub_paths = rng.randi_range(desired_difficulty/2, desired_difficulty)
	sub_path_max_length = ceil(desired_difficulty/3)
	main_path_length = min(5+(desired_difficulty), MAX_MAIN_PATH_ROOMS)

	_average_room_difficulty = desired_difficulty							#already randomized in generator
	_average_difficulty_variation = round(desired_difficulty*0.2)					#already randomized in generator

	var base_room_size = BASE_ROOM_SIZE + $"/root/Player".check("s_level")*1.5 	#needs to be aligned to difficulty

	min_room_size = round(base_room_size-0.1*base_room_size)
	max_room_size = round(base_room_size+0.15*base_room_size)

	min_room_height = 3 + $"/root/Player".check("s_level")/2	#s_level is an integer so it should floor
	max_room_height = min_room_height + 2

	_max_random_walks =  round(min_room_size*0.33)
	_random_walks_widths = rng.randi()%RandomWalksInteriorGenerator.PATH_WIDTHS_TABLES.size()

	_arena_obstacle_per_quadrant = round(rng.randf_range(min_room_size*0.1, min_room_size*0.2))
	_arena_obstacle_min_size = round(min_room_size*0.1)
	_arena_obstacle_max_size = round(min_room_size*0.5)

	_arena_obstacle_outline_thickness = round(min_room_size*0.1)

	if (rng.randi()%100) > 70:
		use_prefabs = true
	else:
		use_prefabs = false

	if $"/root/Player".check("s_level") == 4:
		$"/root/Player".give("e_double_barrel_level", 1)


func apply():
	var generator = get_parent()
	if generator is MapGenerator:
		generator.gen_seed = gen_seed
		generator.make_ceilings = make_ceilings
		generator.main_path_length = main_path_length
		generator.sub_path_max_length = sub_path_max_length
		generator.num_of_sub_paths = num_of_sub_paths
		generator.min_room_size = min_room_size
		generator.max_room_size = max_room_size
		generator.min_room_height = min_room_height
		generator.max_room_height = max_room_height
		generator._average_room_difficulty = _average_room_difficulty
		generator._average_difficulty_variation = _average_difficulty_variation
		generator._max_random_walks = _max_random_walks
		generator._arena_obstacle_per_quadrant = _arena_obstacle_per_quadrant
		generator._arena_obstacle_outline_thickness = _arena_obstacle_outline_thickness
		generator._arena_obstacle_min_size = _arena_obstacle_min_size
		generator._arena_obstacle_max_size = _arena_obstacle_max_size
		if not use_prefabs:
			generator._prefab_rooms = []
		generator._prefabs_on_main = _prefabs_on_main
	else:
		print("This node must be child of MapGenerator")
		return
