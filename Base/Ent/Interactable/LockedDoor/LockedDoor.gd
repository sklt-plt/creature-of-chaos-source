extends Interactable
class_name LockedDoor

func activate():
	if not $StaticBody/CollisionShape.disabled and $"/root/Player".take("r_keys", 1):
		$Trigger/CollisionShape.disabled = true
		$StaticBody/CollisionShape.disabled = true
		var animation_player = get_node_or_null("Model/AnimationPlayer")
		if animation_player:
			$Model/AnimationPlayer.play("hide")
		else:
			$Model.visible = false

func _on_Trigger_body_entered(body):
	if body == $"/root/Player":
		if $"/root/Player".has("r_keys", 1):
			# construct default prompt
			._on_Trigger_body_entered(body)
		else:
			var prompt_text = "You need a key"
			$"/root/Player/HUD".display_dialog(prompt_text)
