extends Node2D
onready var _player : KinematicBody2D = $Player
onready var _tile_map : TileMap = $Navigation2D/TileMap
onready var nav = $Navigation2D
var enemyScene = load("res://Enemies/Bat.tscn")

#export var inner_size := Vector2(11, 11)
#export var perimeter_size := Vector2(1, 1)
#onready var size := inner_size + 2 * perimeter_size

func setup() -> void:
	# TEST version
	var temp_path = ProjectSettings.globalize_path("res://dungeon.txt")
	var img2grid_path = ProjectSettings.globalize_path("res://PhotoToGrid.exe")
	
#	# BUILD version
#	var temp_path = str(OS.get_executable_path().get_base_dir()) + "/dungeon.txt"
#	var img2grid_path = str(OS.get_executable_path().get_base_dir()) + "/PhotoToGrid.exe"

	var file = File.new()
	file.open(temp_path, file.READ)
	
	_tile_map.clear()
	
	var x = 0
	var y = 0
	
	while !file.eof_reached():
		var line = file.get_csv_line()
		
		for item in line:
			if item == "#":
				_tile_map.set_cell(x, y, 1)
				
			elif item == " " or "E" or "S":
				_tile_map.set_cell(x, y, 2)
				
				if item == "E":
					var enemy = enemyScene.instance()
					enemy.position.y = y * 16
					enemy.position.x = x * 16
					add_child(enemy)
					
				if item =="S":
					_player.set_global_position(Vector2((x * 16), (y * 16)))
					
			x += 1
			
		print(line)
		y += 1
		x = 0
	file.close()
	# Sets the game window size to twice the resolution of the world.
	#var map_size_px := size * _tile_map.cell_size
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, map_size_px)
	#OS.set_window_size(1 * map_size_px)
	
	var file_remove = Directory.new()
	file_remove.remove(temp_path)

func _ready() -> void:
	setup()
