extends Node
class_name PlayerStartingEquipment

export var starting_resources = {
	"r_health" : 30,
}

func _ready():
	for sr in starting_resources:
		var current_amount = $"/root/Player".check(sr)
		$"/root/Player".give(sr, max(0, starting_resources[sr]-current_amount))
