extends Node

var top_piece : Spatial
var bottom_piece : Spatial
var left_piece : Spatial
var right_piece : Spatial
var gun_parent

func _ready():
	top_piece = get_node("TopPiece")
	bottom_piece = get_node("BottomPiece")
	left_piece = get_node("LeftPiece")
	right_piece = get_node("RightPiece")
	gun_parent = $"/root/Player/BodyCollision/LookHeight/LookDirection/GunController"

func _physics_process(_delta):
	top_piece.translation.y = gun_parent.current_gun.current_inaccuracy*7

	bottom_piece.translation.y = -gun_parent.current_gun.current_inaccuracy*7

	left_piece.translation.x = -gun_parent.current_gun.current_inaccuracy*7

	right_piece.translation.x = gun_parent.current_gun.current_inaccuracy*7
