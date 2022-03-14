extends Spatial
class_name Interactable

export (String) var prompt_text_suffix = ""
export (AudioStream) var audio_effect

func _ready():
	set_process_input(false)

func activate():
	pass  # override

func playSfx():
	if audio_effect:
		$"/root/Player/SFXPlayer".stream = audio_effect
		$"/root/Player/SFXPlayer".play()

func _input(event):
	if event.is_action_pressed("Interact"):
		activate()

func _on_Trigger_body_entered(body):
	if body == $"/root/Player":
		var prompt_text = "Press "
		var event = InputMap.get_action_list("Interact")[0]
		if event is InputEventKey:
			prompt_text = prompt_text + event.as_text()
		else:
			prompt_text = prompt_text + "Mouse "+String(event.button_index)

		prompt_text = prompt_text + " " + prompt_text_suffix
		$"/root/Player/HUD".display_dialog(prompt_text)
		set_process_input(true)

func _on_Trigger_body_exited(body):
	if body == $"/root/Player":
		$"/root/Player/HUD".hide_dialog()
		set_process_input(false)
