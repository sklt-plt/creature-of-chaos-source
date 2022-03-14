extends Spatial
class_name RoomGeometry

var parent_offset : Vector3

var size

export (NodePath) var tree_ref

const HIDE_ORIGIN = Vector3(-10000,-10000,-10000)

var north_link = {"direction" : 0}
var south_link = {"direction" : 1}
var west_link = {"direction" : 2}
var east_link = {"direction" : 3}

var type = ""
var children = []
var is_enabled = true

func _ready():
	name = "RoomGeometry"

func set_actors(var physics_mode, var enemy_behaviour):
	if children.empty():
		children = get_children()

	for c in children:
		if not is_instance_valid(c):
			continue
		if c is RigidBody:
			c.mode = physics_mode

		if c is KinematicEnemy:
			c.set_awake(enemy_behaviour)

func move_to_offset():
	self.transform.origin = parent_offset
	self.toggle_collisions(true)
	set_actors(RigidBody.MODE_RIGID, true)

func move_away_editor():
	self.transform.origin = HIDE_ORIGIN
	self.toggle_collisions(false)

func move_away():
	set_actors(RigidBody.MODE_STATIC, false)
	move_away_editor()

func available_exits():
	var ret = []
	var maybeDetailMap = get_node_or_null("DetailMap")
	if maybeDetailMap:
		var tiles = maybeDetailMap.get_used_cells()
		for t in tiles:
			if (maybeDetailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_NORTH_EXIT_ID
				and not north_link.has("used") and not ret.has(north_link["direction"])):

				ret.push_back(north_link["direction"])

			if (maybeDetailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_SOUTH_EXIT_ID
				and not south_link.has("used") and not ret.has(south_link["direction"])):

				ret.push_back(south_link["direction"])

			if (maybeDetailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_WEST_EXIT_ID
				and not west_link.has("used") and not ret.has(west_link["direction"])):

				ret.push_back(west_link["direction"])

			if (maybeDetailMap.get_cell_item(t.x, t.y, t.z) == GeneratorConstants.TILE_EAST_EXIT_ID
				and not east_link.has("used") and not ret.has(east_link["direction"])):

				ret.push_back(east_link["direction"])
	else:
		if not north_link.has("used"):
			ret.push_back(north_link["direction"])
		if not south_link.has("used"):
			ret.push_back(south_link["direction"])
		if not west_link.has("used"):
			ret.push_back(west_link["direction"])
		if not east_link.has("used"):
			ret.push_back(east_link["direction"])

	return ret

func used_exits():
	var ret = []
	if north_link.has("used"):
		ret.push_back(north_link)
	if south_link.has("used"):
		ret.push_back(south_link)
	if west_link.has("used"):
		ret.push_back(west_link)
	if east_link.has("used"):
		ret.push_back(east_link)

	return ret

func used_exits_identifiers():
	var ret = []
	if north_link.has("used"):
		ret.push_back(north_link["direction"])
	if south_link.has("used"):
		ret.push_back(south_link["direction"])
	if west_link.has("used"):
		ret.push_back(west_link["direction"])
	if east_link.has("used"):
		ret.push_back(east_link["direction"])

	return ret

func get_link_to_outside():
	var dicts = used_exits()
	for dict in dicts:
		if dict["target"] == "outside":
			return dict

	return null

func toggle_collisions(var enable):
	if is_enabled == enable:
		return

	if not children:
		children = get_children()

	#your friendly optimization code
	for c in children:
		if not is_instance_valid(c):
			continue

		# remove from tree what we can
		if (c is TreasureChest or c is Area
		or c is ResourcePickup or c is RigidBody
		or c is KinematicEnemy):
			if enable:
				self.add_child(c)
			else:
				self.remove_child(c)

		# physics stuff
		if c is CSGBox or c is CSGCombiner:
			c.use_collision = enable
		if c is TreasureChest and not c.is_open:
			var c_lid = c.get_node("Lid")
			var c_trig = c.get_node("Trigger")
			var c_hittrig = c.get_node("HitTrig")
			if enable:
				c_lid.collision_layer = 524291
				c_lid.collision_mask = 524291
				c_trig.collision_layer = 1
				c_trig.collision_mask = 1
				c_hittrig.collision_layer = 5
				c_hittrig.collision_mask = 5
			else:
				c_lid.collision_layer = 0
				c_lid.collision_mask = 0
				c_trig.collision_layer = 0
				c_trig.collision_mask = 0
				c_hittrig.collision_layer = 0
				c_hittrig.collision_mask = 0
		if c is Area:
			if enable:
				c.collision_layer = 1
				c.collision_mask = 1
			else:
				c.collision_layer = 0
				c.collision_mask = 0
		if c is ResourcePickup:
			var c_area = c.get_node("Area")
			if enable:
				c_area.collision_layer = 1
				c_area.collision_mask = 1
			else:
				c_area.collision_layer = 0
				c_area.collision_mask = 0
		if c is RigidBody:
			if enable:
				c.collision_layer = 4
				c.collision_mask = 31
			else:
				c.collision_layer = 0
				c.collision_mask = 0
		if c is GridMap:
			if enable:
				c.collision_layer = 1
				c.collision_mask = 1
			else:
				c.collision_layer = 0
				c.collision_mask = 0

	is_enabled = enable

func get_total_area_for_detail():
	return  ((size.x))*((size.z))

func get_areas_for_detail():
	#default floor - margin
	return {"x0":0,"z0":0,"x1":size.x,"z1":size.z}

