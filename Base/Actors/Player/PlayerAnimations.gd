extends Node
class_name PlayerAnimations

export (float) var animation_lerp_speed = 6

var joy_input = Vector2()

var animation_tree : AnimationTree
var movement_node : PlayerMovement

var playing_slowmo = false
const SLOWMO_TOTAL_TIME = 2.5

func _ready():
	animation_tree = $"../BodyCollision/LookHeight/LookDirection/AnimationTree"
	movement_node = $"../PlayerMovement"

func _process(delta):
	# blend movement animations
	var animation_input = 0

	if joy_input != Vector2.ZERO:
		animation_input = movement_node.get_desired_speed()

	animation_input = range_lerp(animation_input, 0, movement_node.run_speed, 0.0, 1.0)

	var current_blend_amount = animation_tree.get("parameters/WalkingBlend/blend_amount")

	animation_tree.set("parameters/WalkingBlend/blend_amount", lerp(current_blend_amount, animation_input, delta*animation_lerp_speed))

func _on_switch_input():
	# one shot switching animation
	animation_tree.set("parameters/SwitchGun/active", true)

func play_slowmo():
	if not playing_slowmo:
		playing_slowmo = true
		Engine.time_scale = 0.4
		yield(get_tree().create_timer(SLOWMO_TOTAL_TIME), "timeout")
		Engine.time_scale = 1.0
		playing_slowmo = false

