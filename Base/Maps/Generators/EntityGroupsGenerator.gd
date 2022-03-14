extends Node
class_name EntityGroupsGenerator

var _rng
var _owner
var _monster_paths_and_costs
var _pickups
var _int_objects
var _stat_objects

func _init(var owner: Node, var rng: RandomNumberGenerator, var monster_paths_and_costs,
	var pickups, var int_objects: Dictionary,
	var stat_objects: Dictionary):
		_rng = rng
		_owner = owner
		_monster_paths_and_costs = monster_paths_and_costs
		_pickups = pickups
		_int_objects = int_objects
		_stat_objects = stat_objects

func generate(var room_geometry: RoomGeometry):
	var tree_ref = get_node(room_geometry.tree_ref)
	var entities = generate_entity_groups(tree_ref)
	var gmap = room_geometry.get_node("DetailMap")
	place_entities(entities, room_geometry, gmap)

func generate_starting_room(var room_geometry: RoomGeometry):
	# place just starting door for now
	var exits = room_geometry.used_exits()
	for e in exits:
		if e["target"] == "outside":
			var door = _stat_objects["level_entrance"]["ref"].instance()
			room_geometry.add_child(door)
			door.set_owner(owner)

			door.translate_object_local(e["origin"])

			align_door_to_hole(door, e["direction"])

func add_resources_needed_by_monster(var player_resource_costs : Dictionary, var room_resources : Dictionary):
	var player = get_node_or_null("/root/Player")
	var starting_quipment = get_parent().find_node("player_starting_equipment*")

	for c in player_resource_costs:
		# determine if player has equipment that uses resource 'c'
		# if 'c' is ammo for weapon player doesn't have, give x3 the pistol ammo instead
		if (c == "r_shotgun_ammo" and
			(player and not player.has("e_double_barrel_level", 1))):
				room_resources["r_pistol_ammo"] += player_resource_costs[c] * 3
		else:
			# otherwise just append what's needed
			room_resources[c] += player_resource_costs[c]

func generate_entity_groups(var tree_ref : GeneratedRoom):
	var difficulty_pool = tree_ref.difficulty
	var room_monsters = []
	var room_items = []
	var room_specials = []
	var room_resources = {"r_health": 0, "r_shotgun_ammo": 0, "r_pistol_ammo": 0, "r_armor" : 0}

	# random cherry-pick algo for enemies
	# until we exhaust pool
	while difficulty_pool > 0.01:
		var dup_pool = _monster_paths_and_costs.duplicate()
		# filter out too expensive monsters
		for monster in _monster_paths_and_costs:
			if monster["spawn_cost"] > difficulty_pool:
				dup_pool.erase(monster)

		if dup_pool.empty():
			#not enough pool left for any monster
			break

		# pick a monster
		var potential_monster = dup_pool[_rng.randi()%dup_pool.size()]

		difficulty_pool -= potential_monster["spawn_cost"]
		# remember other costs
		add_resources_needed_by_monster(potential_monster["player_resource_costs"], room_resources)

		var new_group = []
		new_group.push_back(potential_monster["ref"])

		# let's have random chance of placing barrel next to it
		if _rng.randf_range(0.0, 1.0) < 0.25:
			new_group.push_back(_int_objects["explosive_barrel"]["ref"])

		room_monsters.push_back(new_group)

	# naive backpack algo for items
	for pickup_type in _pickups:
		var weakest_pickup
		for pickup in _pickups[pickup_type]:
			# remember what is weakest pickup for rounding up impossible remainder
			if not weakest_pickup or pickup["contents"][pickup_type] < weakest_pickup["contents"][pickup_type]:
				weakest_pickup = pickup

			# can we put at least one?
			if (pickup["contents"][pickup_type] > room_resources[pickup_type]):
				continue

			var room_limit = floor(room_resources[pickup_type] / pickup["contents"][pickup_type])

			for _i in range(0, room_limit):
				room_items.push_back([pickup["ref"]])

			room_resources[pickup_type] -= pickup["contents"][pickup_type]*room_limit

		var remainder = float(room_resources[pickup_type])/float(weakest_pickup["contents"][pickup_type])

		if remainder > 0.0 and remainder < 1.0:
			room_items.push_back([weakest_pickup["ref"]])

	# add extra contents like keys
	for t in tree_ref.traits:
		match t:
			GeneratedRoom.ROOM_TRAITS.KEY:
				room_specials.push_back(_int_objects["key"]["ref"])
			GeneratedRoom.ROOM_TRAITS.LOCKED_DOOR:
				room_specials.push_back(_int_objects["locked_door"]["ref"])
			GeneratedRoom.ROOM_TRAITS.EXIT_DOOR:
				room_specials.push_back(_int_objects["level_gate"]["ref"])
			GeneratedRoom.ROOM_TRAITS.TREASURE:
				room_specials.push_back(_int_objects["treasure_chest"]["ref"])
			GeneratedRoom.ROOM_TRAITS.KEY_AND_TREASURE:
				room_specials.push_back(_int_objects["treasure_chest"]["ref"])
				room_specials.push_back(_int_objects["key"]["ref"])

	return {"monsters" : room_monsters, "items" : room_items, "specials" : room_specials}

# old
func get_group_ent_offset(var i: int):
	match i:
		0:
			return Vector3.ZERO
		1:
			return Vector3.LEFT
		2:
			return Vector3.RIGHT
		3:
			return Vector3.FORWARD
		4:
			return Vector3.BACK
		5:
			return Vector3.LEFT+Vector3.FORWARD
		6:
			return Vector3.RIGHT+Vector3.FORWARD
		7:
			return Vector3.LEFT+Vector3.BACK
		8:
			return Vector3.RIGHT+Vector3.BACK
		_:
			return get_group_ent_offset(i-8)*2

func align_door_to_hole(var door, var exit_direction : int):
	match exit_direction:
		1:
			door.rotate_y(deg2rad(180))
			door.translate(Vector3(-2, 0, 0))
		2:
			door.rotate_y(deg2rad(90))
			door.translate(Vector3(-2, 0, 0))
		3:
			door.rotate_y(deg2rad(-90))

func tile_is_not_by_walls(var room_geometry: RoomGeometry, var tile_coords: Vector3):
	return (tile_coords.x != 1 and tile_coords.x != room_geometry.size.x - 1 and
			tile_coords.z != 1 and tile_coords.z != room_geometry.size.z - 1)

func tile_is_walkable_path(var tile_id : int):
	return (tile_id == GeneratorConstants.TILE_RESERVED_PATH_ID or
			tile_id == GeneratorConstants.TILE_RESERVED_SUB_PATH_ID)

func place_entities(var entities: Dictionary, var room_geometry: RoomGeometry, var gmap: GridMap):
	# group tiles
	var monster_available_tiles = []
	var item_available_tiles = []

	if gmap:
		var all_tiles = gmap.get_used_cells()
		for t in all_tiles:
			if (tile_is_walkable_path(gmap.get_cell_item(t.x, t.y, t.z)) and
				tile_is_not_by_walls(room_geometry, t)):
				monster_available_tiles.append(t)
			if gmap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_ITEM_ID:
				item_available_tiles.append(t)

	for ent in entities["specials"]:
		if ent == _int_objects["level_gate"]["ref"]:
			# get link location
			var exits = room_geometry.used_exits()
			for e in exits:
				if e["target"] == "outside":
					var gate = ent.instance()
					room_geometry.add_child(gate)
					gate.set_owner(owner)

					gate.translate_object_local(e["origin"])
					align_door_to_hole(gate, e["direction"])

		elif ent == _int_objects["locked_door"]["ref"]:
			var parent = get_node(room_geometry.tree_ref).get_parent().get_path()
			var exits = room_geometry.used_exits()
			for e in exits:
				if e["target"] != "outside" and get_node(e["target"]).tree_ref == parent:
					var door = ent.instance()
					room_geometry.add_child(door)
					door.set_owner(owner)

					door.translate_object_local(e["origin"])

					align_door_to_hole(door, e["direction"])

		elif (ent == _int_objects["key"]["ref"]
			or ent == _int_objects["treasure_chest"]["ref"]):

			if monster_available_tiles.size() < 1 and ent == _int_objects["key"]["ref"]:
				print ("No room to place entity 'Key'!")
				$"/root/Player".give("r_keys", 1)  # let's just sneak it into player's inventory

			if monster_available_tiles.size() > 0:
				var origin_space_id = _rng.randi()%(monster_available_tiles.size())
				var origin_space = monster_available_tiles[origin_space_id]

				var new_ent = ent.instance()

				room_geometry.add_child(new_ent)
				new_ent.transform.origin = monster_available_tiles[origin_space_id]
				new_ent.scale.x = 0.5*new_ent.scale.x
				new_ent.scale.y = 0.5*new_ent.scale.y
				new_ent.scale.z = 0.5*new_ent.scale.z
				new_ent.set_owner(owner)

				monster_available_tiles.remove(origin_space_id)

	for monster_grp in entities["monsters"]:
		if monster_available_tiles.size() > 0:
			var origin_space_id = _rng.randi()%(monster_available_tiles.size())
			var origin_space = monster_available_tiles[origin_space_id]
			var offset = 0
			for ent in monster_grp:
				if monster_available_tiles.size() > 0:
					var target_space_id = monster_available_tiles.find(origin_space+get_group_ent_offset(offset))
					while target_space_id == -1:
						target_space_id = (origin_space_id+offset)%(monster_available_tiles.size())
						offset += 1

					var new_ent = ent.instance()
					new_ent.rotation_degrees.y = _rng.randi()%360

					room_geometry.add_child(new_ent)
					new_ent.transform.origin = monster_available_tiles[target_space_id]
					if new_ent is RigidBody:
						new_ent.transform.origin.y += 0.5

					new_ent.scale.x = 0.5*new_ent.scale.x
					new_ent.scale.y = 0.5*new_ent.scale.y
					new_ent.scale.z = 0.5*new_ent.scale.z
					new_ent.set_owner(owner)

					monster_available_tiles.remove(target_space_id)
					offset += 1

	for item_grp in entities["items"]:
		if item_available_tiles.size() > 0:
			var origin_space_id = _rng.randi()%(item_available_tiles.size())
			var origin_space = item_available_tiles[origin_space_id]
			var offset = 0
			for ent in item_grp:
				if item_available_tiles.size() > 0:
					var target_space_id = item_available_tiles.find(origin_space+get_group_ent_offset(offset))
					while target_space_id == -1:
						target_space_id = (origin_space_id+offset)%(item_available_tiles.size())
						offset += 1

					var new_ent = ent.instance()

					room_geometry.add_child(new_ent)
					new_ent.transform.origin = item_available_tiles[target_space_id]
					new_ent.set_owner(owner)

					item_available_tiles.remove(target_space_id)
					offset += 1
