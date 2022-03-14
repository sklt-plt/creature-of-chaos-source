extends KinematicBody
class_name Boomerang

export var projectile_speed = 15.0
export var projectile_damage = 20.0
export var return_speed_mul = 1.25
var current_speed

var is_returning = false
var boomerang_owner
var target
var return_delta = 0.0

func _ready():
	current_speed = projectile_speed
	get_node("Model/AnimationPlayer").play("boomerang|boomerang_spin")

func _physics_process(delta):
	var dir = transform.basis.xform(Vector3.FORWARD)

	#check if went past target
	var to_target = target - get_global_transform().origin
	var dot = dir.dot(to_target)
	if dot <= 0 or is_returning:
		is_returning = true
		#should return boomerang
		current_speed = lerp(projectile_speed, projectile_speed * -1, return_delta*return_speed_mul)
		return_delta += delta

	var col = move_and_collide(dir*current_speed*delta)

	if col:
		#deal damage directly
		#behave like boomerang, ignore environment
		if col.collider == boomerang_owner:
			boomerang_owner._on_returned_boomerang()
			queue_free()
		else:
			if hit_target(col):
				set_collision_layer_bit(2, false) #remove from 'enemy' layer which player listens to

func hit_target(var col):
	if col.collider.has_method("deal_damage"):
		col.collider.deal_damage(projectile_damage*1, get_global_transform().origin , null)

		return true
	return false

func _on_Timer_timeout():
	if is_instance_valid(boomerang_owner):
		boomerang_owner._on_returned_boomerang()
	queue_free()
