extends Node
class_name TilesOutlineHelper

static func make_tile_outiline(var possible_tile_ids: Array,
	var trigger_tile: int, var outline_tile_id:int, var gmap: GridMap):

	var tiles = gmap.get_used_cells()
	var floor_tiles = []

	for t in tiles:
		for p in possible_tile_ids:
			if gmap.get_cell_item(t.x, t.y, t.z) == p:
				floor_tiles.append(t)

	for ft in floor_tiles:
		if (gmap.get_cell_item(ft.x+1, ft.y, ft.z) == trigger_tile
			or gmap.get_cell_item(ft.x+1, ft.y, ft.z+1) == trigger_tile
			or gmap.get_cell_item(ft.x, ft.y, ft.z+1) == trigger_tile
			or gmap.get_cell_item(ft.x-1, ft.y, ft.z+1) == trigger_tile
			or gmap.get_cell_item(ft.x-1, ft.y, ft.z) == trigger_tile
			or gmap.get_cell_item(ft.x-1, ft.y, ft.z-1) == trigger_tile
			or gmap.get_cell_item(ft.x, ft.y, ft.z-1) == trigger_tile
			or gmap.get_cell_item(ft.x+1, ft.y, ft.z-1) == trigger_tile
		):
			gmap.set_cell_item(ft.x, ft.y, ft.z, outline_tile_id)
