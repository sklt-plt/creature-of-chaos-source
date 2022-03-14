extends Node
class_name Effects

enum AVAILABLE_SURFACE_EFFECTS {
	DUST,
	BLOOD,
	GREEN_BLOOD,
	FOLIAGE
}

const SURFACE_EFFECTS = {
	AVAILABLE_SURFACE_EFFECTS.DUST : Globals.content_pack_path + "/Effects/HitParticlesDust.tscn",
	AVAILABLE_SURFACE_EFFECTS.BLOOD : Globals.content_pack_path + "/Effects/HitParticlesBlood.tscn",
	AVAILABLE_SURFACE_EFFECTS.GREEN_BLOOD: Globals.content_pack_path + "/Effects/HitParticlesGreenBlood.tscn",
	AVAILABLE_SURFACE_EFFECTS.FOLIAGE: Globals.content_pack_path + "/Effects/HitParticlesFoliage.tscn"
}

