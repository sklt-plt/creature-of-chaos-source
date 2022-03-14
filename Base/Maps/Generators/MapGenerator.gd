extends Spatial
class_name MapGenerator
tool

export (bool) var generate = false
export (bool) var hide_after_generation = false

# interactable objects to load
export (Dictionary) var int_objects = {
	"level_gate" : {"path" : "/Ent/Interactable/LevelExit/LevelExit.tscn"},
	"key" : {"path" : "/Ent/Interactable/Pickups/Key/Key.tscn"},
	"locked_door" : {"path" : "/Ent/Interactable/LockedDoor/LockedDoor.tscn"},
	"treasure_chest" : {"path" : "/Ent/Interactable/TreasureChest/TreasureChest.tscn"},
	"explosive_barrel" : {"path": "/Ent/Interactable/ExplosiveBarrel/ExplosiveBarrel.tscn"}
}

# static objects to load
export (Dictionary) var stat_objects = {
	"level_entrance" : {"path" : "/Ent/Static/LevelEntrance/LevelEntrance.tscn"}
}

export (String) var gen_seed = ""
export (bool) var make_ceilings = false
export (bool) var links_on_floor = true

export (int) var main_path_length = 3
export (int) var sub_path_max_length = 3
export (int) var num_of_sub_paths = 3

export (int) var min_room_size = 10
export (int) var max_room_size = 30
export (int) var min_room_height = 3
export (int) var max_room_height = 4

export (Array, String) var floor_material_paths = ["/Maps/Materials/ep0/ground.tres"]
var _floor_materials = []

export (Array, String) var wall_material_paths = ["/Maps/Materials/ep0/walls.tres"]
var _wall_materials = []

export (Array, String) var ceiling_material_paths = ["/Maps/Materials/ep0/walls.tres"]
var _ceiling_materials = []

export (String) var _detail_tileset_path = "/Maps/Tiles/TilesEp0.tres"

# enemies paths to load from, their per-room cost and player resource recompensation
# note: at least one enemy MUST HAVE a cost of non-zero
export (Array, Dictionary) var monster_paths_and_costs = [
	{"path": "/Actors/Enemies/Projectiles/enemy.tscn", "spawn_cost": 1.0, "spawn_max_group": 3, "player_resource_costs": {"r_health": 2, "r_pistol_ammo": 4, "r_armor" : 2}},
	{"path": "/Actors/Enemies/Melee/enemy.tscn", "spawn_cost": 2.5, "spawn_max_group": 2, "player_resource_costs": {"r_health": 3, "r_shotgun_ammo": 2, "r_armor" : 2}},
	{"path": "/Actors/Enemies/Boomerangs/enemy.tscn", "spawn_cost": 1.5, "spawn_max_group": 3, "player_resource_costs": {"r_health": 2, "r_shotgun_ammo": 2, "r_armor" : 2}}]

export (float) var _average_room_difficulty = 10				# per-room budget for enemies (enemy cost declared above)
export (float) var _average_difficulty_variation = 5				# how much deviation from budget can a room have (rooms balance this in pairs)

# pickups to load, their contents are taken from inside their scripts
# note: each group needs to be sorted by strongest
export (Dictionary) var pickups = {
	"r_shotgun_ammo" : [
		{"path": "/Ent/Interactable/Pickups/Ammo/AmmoShotgunPickup.tscn"}],
	"r_pistol_ammo" : [
		{"path": "/Ent/Interactable/Pickups/Ammo/AmmoPistolPickup.tscn"}],
	"r_health" : [
		{"path": "/Ent/Interactable/Pickups/Health/HealthPickupL.tscn"},
		{"path": "/Ent/Interactable/Pickups/Health/HealthPickupM.tscn"},
		{"path": "/Ent/Interactable/Pickups/Health/HealthPickupS.tscn"}],
	"r_armor" : [
		{"path": "/Ent/Interactable/Pickups/Armor/ArmorPickupL.tscn"},
		{"path": "/Ent/Interactable/Pickups/Armor/ArmorPickupM.tscn"},
		{"path": "/Ent/Interactable/Pickups/Armor/ArmorPickupS.tscn"}]
}

export (int) var _max_random_walks = RandomWalksInteriorGenerator.DEF_NUM_OF_RANDOM_PATHS	# how many random walkt to take in corridor rooms
export (RandomWalksInteriorGenerator.PATH_WIDTHS_OTHERS) var _random_walks_widths			# which distribution of random paths to use, see definition in RandomWalksInteriorGenerator

export (int) var _arena_obstacle_per_quadrant = 2			# how many obstacles to create in arena rooms, per each 1/4th of room
export (int) var _arena_obstacle_outline_thickness = 2		# how big the "safe zone" to spawn objects around obstacles will be reserved
export (int) var _arena_obstacle_min_size = 1
export (int) var _arena_obstacle_max_size = 5
export (bool) var _arena_symmetry = false				# unused for now

export (Array, Dictionary) var _prefab_rooms = [		# custom rooms to load
	{"path": "/Maps/PrefabRooms/HollowHedge.tscn"},
	{"path": "/Maps/PrefabRooms/UpDown.tscn"},
	{"path": "/Maps/PrefabRooms/Pond.tscn"}]

export (bool) var _prefabs_on_main = true				# if true, custom rooms will only appear on main path

const HIDE_ORIGIN = Vector3(-10000, -10000, -10000)

var _rooms_data_generator
var _walls_generator
var _random_walks_interior_generator
var _entity_generator
var _arena_generator
var _starting_equipment

var _generated_tree_root
var _owner
var _rng

func _ready():
	if not Engine.is_editor_hint():
		generate = true
		hide_after_generation = true

func clear_refs():
	pass

func is_generating():
	return generate

func _process(_delta):
	if generate:
		var maybe_overrides = self.get_node_or_null("GeneratorOverrides")

		if maybe_overrides:
			if not maybe_overrides.done:
				return
			else:
				maybe_overrides.apply()

		if (prepare()):

			_generated_tree_root = _rooms_data_generator.generate_design_tree(main_path_length, num_of_sub_paths)

			generate_pass_one(_generated_tree_root)

			generate_pass_two(_generated_tree_root)

			_generated_tree_root.transform = _generated_tree_root.transform.scaled(Vector3(2,2,2))
			get_node(_generated_tree_root.get_node("starting_room").geometry).toggle_collisions(true)

			if hide_after_generation:
				hide_rooms(_generated_tree_root)

			teleport_player_to_entrance()

			if not Engine.is_editor_hint():
				$"/root/Player".refresh_shaders()

		generate = false

		print("Generation done")

func teleport_player_to_entrance():
	var starting_room_geometry = get_node(get_node(String(_generated_tree_root.get_path())+"/starting_room").geometry)
	var entrance_link = starting_room_geometry.get_link_to_outside()
	var player_spawn_translation = entrance_link["origin"]*2

	var offset
	var offset_rot = 0
	match entrance_link["direction"]:
		0:
			offset = Vector3(1, 0, 1)
			offset_rot = 180
		1:
			offset = Vector3(1, 0, -1)
		2:
			offset = Vector3(1, 0, 1)
			offset_rot = -90
		3:
			offset = Vector3(-1, 0, 1)
			offset_rot = 90

	player_spawn_translation += offset

	if not Engine.is_editor_hint():
		var tele = ManualPlayerSpawn.new()
		tele.name = "PlayerSpawn"
		tele.translation = player_spawn_translation
		tele.rotation_degrees.y = offset_rot
		get_parent().add_child(tele)

func randomize_seed():
	_rng.randomize()
	gen_seed = String(_rng.randi())
	print("Generating with seed: ", gen_seed)
	_rng.set_seed(gen_seed.hash())

func prepare():
	# clear ai cache
	if not Engine.is_editor_hint():
		$"/root/AIManager".clear_registrations()

	# load interactables
	int_objects["level_gate"]["ref"] = load(Globals.content_pack_path + int_objects["level_gate"]["path"])
	int_objects["key"]["ref"] = load(Globals.content_pack_path + int_objects["key"]["path"])
	int_objects["locked_door"]["ref"] = load(Globals.content_pack_path + int_objects["locked_door"]["path"])
	int_objects["treasure_chest"]["ref"] = load(Globals.content_pack_path + int_objects["treasure_chest"]["path"])
	int_objects["explosive_barrel"]["ref"] = load(Globals.content_pack_path + int_objects["explosive_barrel"]["path"])

	# load static props
	stat_objects["level_entrance"]["ref"] = load(Globals.content_pack_path + stat_objects["level_entrance"]["path"])

	# reload materials
	_floor_materials.clear()
	for mS in floor_material_paths:
		_floor_materials.push_back(load(Globals.content_pack_path + mS))

	_wall_materials.clear()
	for mS in wall_material_paths:
		_wall_materials.push_back(load(Globals.content_pack_path + mS))

	_ceiling_materials.clear()
	for mS in ceiling_material_paths:
		_ceiling_materials.push_back(load(Globals.content_pack_path + mS))

	# prepare rng
	_rng = RandomNumberGenerator.new()

	if not Engine.is_editor_hint():
		if ((EpisodeManager.is_normal_episode_playing() and Globals.user_settings["legacy_campaign"] and not gen_seed.empty()) or
			EpisodeManager.is_custom_episode_playing() and not gen_seed.empty()):
			_rng.set_seed(gen_seed.hash())
		else:
			randomize_seed()
	else:
		if gen_seed.empty():
			randomize_seed()
		else:
			_rng.set_seed(gen_seed.hash())

	# needed for every new node?
	_owner = get_parent()

	# flush existing rooms
	var oldMap = get_parent().find_node("generated_map*")
	if oldMap:
		oldMap.queue_free()

	# create helper objects
	_rooms_data_generator = null
	var oldDG = get_parent().find_node("rooms_data_generator*")
	if oldDG:
		oldDG.queue_free()
		_rooms_data_generator = null

	for pr in _prefab_rooms:
		pr["ref"] = load(Globals.content_pack_path + pr["path"])

	if not _rooms_data_generator:
		_rooms_data_generator = RoomsDataGenerator.new(_rng,
			_average_room_difficulty, _average_difficulty_variation, min_room_size,
			max_room_size, min_room_height, max_room_height, sub_path_max_length, _prefab_rooms, _prefabs_on_main)

		get_parent().add_child(_rooms_data_generator)
		_rooms_data_generator.set_name("rooms_data_generator")
		_rooms_data_generator.set_owner(_owner)

	var oldWG = get_parent().find_node("walls_generator*")
	if oldWG:
		oldWG.queue_free()
		_walls_generator = null

	if not _walls_generator:
		_walls_generator = RoomWallsGenerator.new(_owner, _wall_materials,
			_floor_materials, _ceiling_materials, make_ceilings, links_on_floor)

		_walls_generator.set_name("walls_generator")

		get_parent().add_child(_walls_generator)
		_walls_generator.set_owner(_owner)
		_walls_generator.set_rng(_rng)

	var oldLG = get_parent().find_node("random_walks_interior_generator*")
	if oldLG:
		oldLG.queue_free()
		_random_walks_interior_generator = null

	if not _random_walks_interior_generator:
		_random_walks_interior_generator = RandomWalksInteriorGenerator.new(_owner, _detail_tileset_path,
			_rng, _random_walks_widths, _max_random_walks)

		_random_walks_interior_generator.set_name("random_walks_interior_generator")

		get_parent().add_child(_random_walks_interior_generator)
		_random_walks_interior_generator.set_owner(_owner)

	_random_walks_interior_generator._rng = _rng

	var oldAG = get_parent().find_node("arena_interior_generator*")
	if oldAG:
		oldAG.queue_free()
		_arena_generator = null

	if not _arena_generator:
		_arena_generator = ArenaGenerator.new(_owner, _detail_tileset_path, _rng,
			_arena_symmetry, _arena_obstacle_per_quadrant, _arena_obstacle_outline_thickness,
			_arena_obstacle_min_size, _arena_obstacle_max_size)

		_arena_generator.set_name("arena_interior_generator")

		get_parent().add_child(_arena_generator)
		_arena_generator.set_owner(_owner)

	_arena_generator._rng = _rng

	var oldSE = get_parent().find_node("player_starting_equipment*")
	if not oldSE:
		_starting_equipment = PlayerStartingEquipment.new()
		_starting_equipment.set_name("player_starting_equipment")
		get_parent().add_child(_starting_equipment)
		_starting_equipment.set_owner(_owner)

	# load monster refs
	for m in monster_paths_and_costs:
		m["ref"] = load(Globals.content_pack_path + m["path"])

	# load pickups
	for pickup_type in pickups:
		for pickup in pickups[pickup_type]:
			pickup["ref"] = load(Globals.content_pack_path + pickup["path"])
			var temp = pickup["ref"].instance()
			pickup["contents"] = temp.get("contents").duplicate()

	var oldEG = get_parent().find_node("entity_groups_generator*")
	if oldEG:
		oldEG.queue_free()
		_entity_generator = null

	if not _entity_generator:
		_entity_generator = EntityGroupsGenerator.new(_owner, _rng, monster_paths_and_costs,
			pickups, int_objects, stat_objects)

		_entity_generator.set_name("entity_groups_generator")

		get_parent().add_child(_entity_generator)
		_entity_generator.set_owner(_owner)

	_entity_generator._rng = _rng

	return true

func generate_pass_one(var root):
	var rooms = root.get_children()

	for r in rooms:
		if r is GeneratedRoom:
			var new_room_geometry = _walls_generator.prepare_room_geometry(r, _generated_tree_root)

			if r.prefab_room:
				var prefab_gridmap = r.prefab_room.instance()
				new_room_geometry.add_child(prefab_gridmap)
				prefab_gridmap.owner = _owner
				GridMapHelper.configure_surface_type(prefab_gridmap)

			_walls_generator.make_walls(r, new_room_geometry)

			create_room_boundary(r, 0)

		if r.get_child_count() > 0:
			generate_pass_one(r)

func generate_pass_two(var root):
	var nodes = root.get_children()

	for node in nodes:
		if node is RoomGeometry:
			# what room interior to make
			var gen_room = get_node(node.tree_ref)

			if gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.STARTING):
				_entity_generator.generate_starting_room(node)

			if gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.NORMAL_CORRIDORS):
				if not gen_room.prefab_room:
					_random_walks_interior_generator.generate(node)
				_entity_generator.generate(node)

			elif gen_room.traits.has(GeneratedRoom.ROOM_TRAITS.ARENA):
				_arena_generator.generate(node)
				_entity_generator.generate(node)

		if node is GeneratedRoom:
			if node.traits.has(GeneratedRoom.ROOM_TRAITS.STARTING):
				_walls_generator.make_level_entrance(node)

			var childRooms = node.get_children()
			for c in childRooms:
				if c is GeneratedRoom:
					_walls_generator.make_exit(node, c)

			if node.get_child_count() > 0:
				generate_pass_two(node)

			if node.traits.has(GeneratedRoom.ROOM_TRAITS.END_MAIN):
				_walls_generator.make_level_exit(node)

func create_room_boundary(var room, var boundary_margin):
	# crate area collider
	var a = Area.new()
	a.monitoring = false
	var rg = get_node(room.geometry)
	rg.add_child(a)
	a.set_owner(_owner)
	a.add_to_group("RoomBoundaries")

	var center = Vector3(rg.size.x/2, rg.size.y/2, rg.size.z/2)
	a.translate(center)

	# create collision shape
	var cs = CollisionShape.new()
	a.add_child(cs)
	cs.set_owner(_owner)

	# create shape
	var bs = BoxShape.new()
	bs.extents = Vector3((rg.size.x+boundary_margin)/2, (rg.size.y+boundary_margin)/2, (rg.size.z+boundary_margin)/2)
	cs.shape = bs

func hide_rooms(var root):
	var rooms = root.get_children()

	for r in rooms:
		var childRooms = r.get_children()

		for c in childRooms:
			if c is GeneratedRoom and not c.traits.has(GeneratedRoom.ROOM_TRAITS.STARTING):
				var g = get_node(c.geometry)
				if not Engine.is_editor_hint():
					g.move_away()
				else:
					g.move_away_editor()

		if r.get_child_count() > 0:
			hide_rooms(r)
