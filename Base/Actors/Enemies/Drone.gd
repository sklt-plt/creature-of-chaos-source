extends Path
class_name Drone

export (float) var speed = 1
export (PackedScene) var projectile
export (float) var targeting_height_offset = 0.5
export (PackedScene) var destroy_effect

var pf

func _ready():
	pf = $PathFollow

func _physics_process(delta):
	pf.offset += delta*speed

func destroy():
	if destroy_effect:
		var ef = destroy_effect.instance()
		get_parent().add_child(ef)
		ef.global_transform.origin = pf.get_global_transform().origin + curve.interpolate_baked(pf.offset)
		ef.one_shot = true
	queue_free()

func _on_ProjectileSpawnTimer_timeout():
	var pos = pf.get_global_transform().origin + curve.interpolate_baked(pf.offset)
	var target_pos = $"/root/Player".get_global_transform().origin
	target_pos += Vector3(0, targeting_height_offset, 0)

	if projectile:
		ProjectileSpawnHelper.spawn_projectile(projectile, get_tree().current_scene, pos, target_pos)

