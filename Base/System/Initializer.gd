extends Node

func _ready():
	# load content pack
	if not ProjectSettings.load_resource_pack(Globals.content_pack_path + ".pck"):
		print("Cannot load resource pack: ", Globals.content_pack_path, ".pck, will attempt to use folder structure")

	#load stuff from active content pack
	#object cache
	var object_cache = load(Globals.content_pack_path + "/Ent/ObjectCache.tscn")
	if object_cache:
		$"/root".call_deferred("add_child", object_cache.instance())
	else:
		print("Cannot load: ", Globals.content_pack_path, "/Ent/ObjectCache.tscn")

	#load fonts
	var font_scene = load(Globals.content_pack_path + "/UI/FontCache.tscn")
	if font_scene:
		$"/root".call_deferred("add_child", font_scene.instance())
	else:
		print("Cannot load: ", Globals.content_pack_path + "/UI/FontCache.tscn")

	# load player
	var player_scene = load(Globals.content_pack_path + "/Actors/Player/Player.tscn")

	if player_scene:
		$"/root".call_deferred("add_child", player_scene.instance())
	else:
		print("Cannot load: ", Globals.content_pack_path, "/Actors/Player/Player.tscn")

func on_player_ready():
	$"/root/Globals".load_user_settings()
	$"/root/Globals".load_user_inputs()
	$"/root/Globals".load_user_progress()

	# finally load main menu
	if get_tree().change_scene(Globals.content_pack_path + "/MainMenu/MainMenu.tscn") != OK:
		print("Can't load: ", Globals.content_pack_path + "/MainMenu/MainMenu.tscn")
