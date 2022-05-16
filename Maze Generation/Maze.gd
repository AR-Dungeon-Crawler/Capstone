extends Node2D

const N = 1
const E = 1
const S = 1
const W = 1

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 16  # tile size (in pixels)
var width = 12  # width of map (in tiles)
var height = 10  # height of map (in tiles)
var rng = RandomNumberGenerator.new()
var player_coordinates
var bat_coordinates
var bat_locations_array = []

# get a reference to the map for convenience
onready var Map = $TileMap
onready var player = get_parent().get_parent().get_node("Player")

func _ready():
	rng.randomize()
	tile_size = Map.cell_size
	make_maze()
	
	
func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list
	
func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with wall tiles initially 
	Map.clear()
	
	# set the player and bat locations to be a walkable tile. This needs to be updated so 
	# the player and bat can start on random locations 
	player_coordinates = (Vector2(round(player.global_position[0] / 16), round(player.global_position[1] / 16)))
	Map.set_cellv(player_coordinates, 2)
	
	for bat in get_tree().get_nodes_in_group("Enemy"):
		bat_coordinates = (Vector2(round(bat.global_position[0] / 16), round(bat.global_position[1] / 16)))
		bat_locations_array.append(bat_coordinates)
		Map.set_cellv(bat_coordinates, 2)
		
	for x in range(width):
		for y in range(height):
			if Vector2(x, y) in bat_locations_array or Vector2(x, y) == player_coordinates:
				continue
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), 1)
		
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			# pick a random neighbor cell and append to stack
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# set current and next cell to be either a wall or walkable tile
			Map.set_cellv(current, rng.randi_range(1, 2))
			Map.set_cellv(next, rng.randi_range(1, 2))
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		yield(get_tree(), "idle_frame")
	
	# add additional layer of wall to the existing maze 
	for x in range(-1, width + 1):
		for y in range(-1, height + 1):
			if x == -1 or x == width or y == -1 or y == height:
				Map.set_cellv(Vector2(x, y), 1)
				yield(get_tree(), "idle_frame")
