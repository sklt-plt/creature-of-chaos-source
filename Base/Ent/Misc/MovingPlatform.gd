extends Path

enum startModes {
	off,
	on,
	on_player
}

enum loopMode {
	continous,
	ping_pong
}

enum pauseMode {
	never,
	after_full_loop,
	at_either_end
}

export (startModes) var start
export (loopMode) var loop
export (pauseMode) var pause
export (float) var speed = 0.25

var awake = false
var standing = []
var direction = 1
var previousPos

func _ready():
	$PathFollow/Platform/FloorTrigger/CollisionShapeCpy.shape = $PathFollow/Platform/CollisionShape.shape

	startIfOn()

	updatePreviousPos()

func _physics_process(delta):
	if awake:
		#move self
		var new_offset = clamp($PathFollow.unit_offset + speed * delta * direction, 0.0, 0.999) #translation from PathFollow.unit_offset is same for 0.0 and 1.0
		$PathFollow.unit_offset = new_offset


		if $PathFollow.unit_offset >= 0.998 or $PathFollow.unit_offset == 0.0:
			if loop == loopMode.continous:
				$PathFollow.unit_offset -= 0.998
			if loop == loopMode.ping_pong:
				direction = direction * -1

			if pause == pauseMode.at_either_end:
				awake = false

		if pause == pauseMode.after_full_loop and $PathFollow.unit_offset == 0.0:
			awake = false

		var diff = $PathFollow.translation - previousPos

#		platform.move_and_collide(diff)

#		if rotate:
#			platform.rotation_degrees = $PathFollow.rotation_degrees

		#move standing

		for body in standing:
			if body.has_method("push_instant"):
				body.push_instant(diff*-61.5)

		updatePreviousPos()


func updatePreviousPos():
	previousPos = $PathFollow.translation

func _on_FloorTrigger_body_entered(body):
	if start == startModes.on_player and body.is_in_group("PlayerTeam"):
		awake = true

	standing.append(body)

func _on_FloorTrigger_body_exited(body):
	standing.erase(body)

func startIfOn():
	if start == startModes.on:
		awake = true
	elif start == startModes.off:
		awake = false

func on_button_pushed():
	startIfOn()
