extends KinematicBody

class_name AutomaticDoor

export (bool) var unlocked
export (float) var stayOpenTime

func on_button_pushed():
	unlocked = true
	openIfAPlayerIsNearby()

func openIfAPlayerIsNearby():
	var bodies = $CollisionShape/MotionDetectorArea.get_overlapping_bodies()

	for player in get_tree().get_nodes_in_group("PlayerTeam"):
		if bodies.has(player):
			open()
			break

func on_MotionDetectorArea_body_entered(body):
	if unlocked and body.is_in_group("PlayerTeam"):
		open()

func open():
	$CollisionShape/MeshInstance/AnimationPlayer.play("open")
	if stayOpenTime > 0:
		$AutoCloseTimer.start(stayOpenTime)

func on_AutoCloseTimer_timeout():
	print("door closed")
	$CollisionShape/MeshInstance/AnimationPlayer.play_backwards("open")
