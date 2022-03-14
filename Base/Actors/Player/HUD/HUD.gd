extends Control

var hurt_effetct : ColorRect
var health_current : Label
var health_total : Label
var health_bar : TextureProgress

var armor_current : Label
var armor_total : Label
var armor_bar : TextureProgress

var ammo_current : Label
var ammo_total : Label
var ammo_type : TextureRect
var ammo_bar : TextureProgress
export (Array, Texture) var ammo_sprites

var boss_health_group : Control
var boss_health_bar1 : TextureProgress
var boss_health_bar2 : TextureProgress

var keys_current: Label

var arcade_container : Control
var arcade_level : Label
var arcade_time : Label
var arcade_time_freeze : Label
var arcade_score : Label

var boss_enemy_node

var current_gun_index = 0

func _ready():
	hurt_effetct = get_node("HurtEffect")
	health_current = get_node("Health/Bar/CenterContainer/HSplitContainer/Current")
	health_total = get_node("Health/Bar/CenterContainer/HSplitContainer/Total")
	health_bar = get_node("Health/Bar")

	armor_current = get_node("Armor/Bar/CenterContainer/HSplitContainer/Current")
	armor_total = get_node("Armor/Bar/CenterContainer/HSplitContainer/Total")
	armor_bar = get_node("Armor/Bar")

	ammo_current = get_node("Ammo/Bar/CenterContainer/HSplitContainer/Current")
	ammo_total = get_node("Ammo/Bar/CenterContainer/HSplitContainer/Total")
	ammo_type = get_node("Ammo/Bar/Type")
	ammo_bar = get_node("Ammo/Bar")

	keys_current = get_node("Keys/KeyCount/Current")
	if not ammo_sprites.empty():
		ammo_type.texture = ammo_sprites[0]

	boss_health_group = get_node("BossHealth")
	boss_health_bar1 = get_node("BossHealth/Bar")
	boss_health_bar2 = get_node("BossHealth/Bar2")

	arcade_container = get_node("Arcade")
	arcade_level = get_node("Arcade/LevelC/Level")
	arcade_time = get_node("Arcade/TimeC/TimeVal")
	arcade_time_freeze = get_node("Arcade/TimeC/TextureRect/TimeFreezeVal")
	arcade_score = get_node("Arcade/ScoreC/Score")

func register_boss_health(var node : Node, var boss_name: String):
	boss_enemy_node = node
	boss_health_bar1.max_value = boss_enemy_node.health
	boss_health_bar2.max_value = boss_enemy_node.health
	$BossHealth/CenterContainer/HSplitContainer/Name.text = boss_name
	boss_health_group.visible = true

func deregister_boss_health():
	boss_health_group.visible = false
	boss_enemy_node = null

func _physics_process(delta):
	#update hurt effect
	hurt_effetct.color.a = lerp(hurt_effetct.color.a, 0.0, 2*delta)

	#update health bar
	health_current.text = String(floor(max($"/root/Player".check("r_health"), 0.0)))
	health_total.text = String($"/root/Player".check_limit("r_health"))
	health_bar.value = max($"/root/Player".check("r_health"), 0.0)
	health_bar.max_value = $"/root/Player".check_limit("r_health")

	#update armor bar
	armor_current.text = String(floor(max($"/root/Player".check("r_armor"), 0.0)))
	armor_total.text = String($"/root/Player".check_limit("r_armor"))
	armor_bar.value = max($"/root/Player".check("r_armor"), 0.0)
	armor_bar.max_value = $"/root/Player".check_limit("r_armor")

	var bonus_ammo_cap = $"/root/Player/PlayerResources".ammo_bonus_cap

	#update ammo counter
	match current_gun_index:
		0:
			ammo_current.text = String($"/root/Player".check("r_pistol_ammo"))
			ammo_total.text = String($"/root/Player".check_limit("r_pistol_ammo")+bonus_ammo_cap)
			ammo_bar.value = $"/root/Player".check("r_pistol_ammo")
			ammo_bar.max_value = $"/root/Player".check_limit("r_pistol_ammo")+bonus_ammo_cap
		1:
			ammo_current.text = String($"/root/Player".check("r_shotgun_ammo"))
			ammo_total.text = String($"/root/Player".check_limit("r_shotgun_ammo")+bonus_ammo_cap)
			ammo_bar.value = $"/root/Player".check("r_shotgun_ammo")
			ammo_bar.max_value = $"/root/Player".check_limit("r_shotgun_ammo")+bonus_ammo_cap

	keys_current.text = String(max($"/root/Player".check("r_keys"), 0.0))

	if boss_enemy_node:
		boss_health_bar1.value = boss_enemy_node.health
		boss_health_bar2.value = boss_enemy_node.health

	if arcade_container.visible:
		arcade_level.text = String($"/root/Player".check("s_level"))
		arcade_score.text = String($"/root/Player".check("s_score"))

		var time_left = $"/root/Player".check("r_time_left")
		arcade_time.text = TimeHelper.float_to_min_sec_str(time_left)
		arcade_time_freeze.text = "%.1f" % $"/root/Player".check("r_time_freeze")

func update_gun_index(var gun_index: int):
	current_gun_index = gun_index
	if ammo_sprites.size() > gun_index:
		ammo_type.texture = ammo_sprites[gun_index]

func display_dialog(var text):
	var dialog_text = $DialogText
	dialog_text.visible = true
	dialog_text.text = text

func hide_dialog():
	$DialogText.visible = false
