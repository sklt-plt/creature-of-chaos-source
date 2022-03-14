extends WorldEnvironment

func _ready():
	update_to_settings()

func update_to_settings():
	self.environment.ssao_enabled = Globals.user_settings["ao"]
	$DirectionalLight.shadow_enabled = Globals.user_settings["shadows"]
