extends Interactable
class_name TreasureChest

var is_open = false
var prioritize_new_weapon = false

var effect_coroutine
export (Array, Dictionary) var powerups = [
	{"path": "/Ent/Interactable/Powerups/HealthPowerup.tscn", "resource_name": "r_health"},
	{"path": "/Ent/Interactable/Powerups/ArmorPowerup.tscn", "resource_name": "r_armor"},
	{"path": "/Ent/Interactable/Powerups/AmmoPowerup.tscn", "resource_name": "ammo_bonus_cap"}
]

export (Array, Dictionary) var gun_powerups = [
	{"path": "/Ent/Interactable/Powerups/ShotgunPowerup.tscn", "resource_name": "e_double_barrel_level"}
]

var spawn_pos

func _ready():
	spawn_pos = get_node("ItemSpawnPos")

	for i in range(0, powerups.size()):
		powerups[i]["ref"] = load(Globals.content_pack_path + powerups[i]["path"])
	for i in range(0, gun_powerups.size()):
		gun_powerups[i]["ref"] = load(Globals.content_pack_path + gun_powerups[i]["path"])

	$"/root/Player".give("s_treasure_possible", 1)

func activate():
	is_open = true
	#"animate" lid with physics
	var lid : RigidBody
	var rng = RandomNumberGenerator.new()

	rng.randomize()

	lid = get_node("Lid")
	lid.mode = RigidBody.MODE_RIGID
	lid.apply_impulse(Vector3.ZERO+Vector3(rng.randf_range(-2.0, 2.0), rng.randf_range(-2.0, 2.0), rng.randf_range(-2.0, 2.0)),
		Vector3.UP+Vector3(rng.randf_range(-2.0, 2.0), rng.randf_range(-2.0, 2.0), rng.randf_range(-2.0, 2.0)))

	#animate material
	effect_coroutine = dissapear()

	#delete user prompt
	$Trigger.collision_layer = 0
	$Trigger.collision_mask = 0
	$HitTrig.collision_layer = 0
	$HitTrig.collision_mask = 0

	#collect only legal powerups for spawning
	var allowed_powerups = []

	for p in powerups:
		if $"/root/Player/PlayerResources".check_limit(p["resource_name"]) < $"/root/Player/PlayerResources".resource_max_upgrades[p["resource_name"]]:
			allowed_powerups.append(p["ref"])

	for p in gun_powerups:
		if ($"/root/Player".check(p["resource_name"]) > 0 and
			$"/root/Player".check(p["resource_name"]) < $"/root/Player".check_limit(p["resource_name"])):
			allowed_powerups.append(p["ref"])

	#spawn goodies
	if allowed_powerups.empty():
		return  # give something else maybe...

	var new_powerup = allowed_powerups[rng.randi()%allowed_powerups.size()].instance()
	spawn_pos.add_child(new_powerup)

	$"/root/Player".give("s_treasure_open", 1)

func dissapear():
	var lid_model = $Lid/model.get_child(0)
	var new_material = lid_model.get("material/0").duplicate()
	lid_model.material_override = new_material
	new_material.flags_transparent = true

	while(new_material.albedo_color.a > 0.001):
		new_material.albedo_color.a -= 0.01
		if not self.is_inside_tree():
			new_material.albedo_color.a = 0.0
			break
		yield(get_tree(), "idle_frame")

	$Lid.mode = RigidBody.MODE_STATIC
	$Lid.collision_layer = 0
	$Lid.collision_mask = 0
