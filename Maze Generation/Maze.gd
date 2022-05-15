extends Node2D

const N = 1
const E = 1
const S = 1
const W = 1

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 64  # tile size (in pixels)
var width = 12  # width of map (in tiles)
var height = 10  # height of map (in tiles)
var rng = RandomNumberGenerator.new()

# get a reference to the map for convenience
onready var Map = $TileMap

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
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), 1)
			 
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			print("dir ", dir)
			print("Map.get_cellv ", Map.get_cellv(current))
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]
			print("current_walls ", current_walls)
			print("next_walls ", next_walls)
			Map.set_cellv(current, rng.randi_range(1, 2))
			Map.set_cellv(next, rng.randi_range(1, 2))
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		yield(get_tree(), "idle_frame")
	
	for x in range(-1, width + 1):
		for y in range(-1, height + 1):
			if x == -1 or x == width or y == -1 or y == height:
				Map.set_cellv(Vector2(x, y), 1)
				yield(get_tree(), "idle_frame")
