extends Interactable
class_name BasePowerup

export (bool) var rise_effect = true
export (bool) var fade_in_effect = true

var effect_coroutine

func activate():
	if $"/root/EpisodeManager".is_endless_episode_playing():
		$"/root/Player".give("s_leveled_score", 100)
		$"/root/Player".give("r_time_left", 5.0)

func _ready():
	if rise_effect:
		$AnimationPlayer.play("Rise")

	if fade_in_effect:
		effect_coroutine = material_effect()

func material_effect():
	var new_material = $Sphere.get("material/0").duplicate()
	$Sphere.material_override = new_material

	var icons = $Sphere.get_children()
	var new_material_icons = []

	for i in range(0, icons.size()):
		new_material_icons.append(icons[i].get("material/0").duplicate())
		icons[i].material_override = new_material_icons[i]

	new_material.flags_transparent = true

	for m in new_material_icons:
		m.flags_transparent = true

	new_material.albedo_color.a = 0.0

	for m in new_material_icons:
		m.albedo_color.a = 0.0

	while(new_material.albedo_color.a < 0.75):
		new_material.albedo_color.a += 0.025
		for m in new_material_icons:
			m.albedo_color.a += 0.025

		yield(get_tree(), "idle_frame")

	while(new_material_icons[0].albedo_color.a < 1.0):
		for m in new_material_icons:
			m.albedo_color.a += 0.025

		yield(get_tree(), "idle_frame")
