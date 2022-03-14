extends KinematicBody
class_name BaseProjectile

export (float) var speed = 1.0

func _physics_process(delta):
	var dir = transform.basis.xform(Vector3.FORWARD)
	var col = move_and_collide(dir*speed*delta, false, true, false)

	if col:
		hit_target(col)
		queue_free()

func hit_target(var _col : KinematicCollision):
	pass  # override me

func _on_DecayTimer_timeout():
	queue_free()
