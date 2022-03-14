extends Particles

const light_flash_speed = 3

func _ready():
	one_shot = true

func _physics_process(delta):
	var light = get_node_or_null("OmniLight")
	if light and light.light_energy > 0.01:
		light.light_energy -= delta * light_flash_speed

	if not self.emitting and not $AudioStreamPlayer3D.stream_paused and light.light_energy < 0.011:
		queue_free()
