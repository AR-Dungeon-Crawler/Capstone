extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Sets the game window size to twice the resolution of the world.
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, map_size_px)
	#OS.set_window_size(64 * Vector2(16, 9))
	# TEST version
#	var temp_path = ProjectSettings.globalize_path("res://dungeon.txt")
#	var img2grid_path = ProjectSettings.globalize_path("res://PhotoToGrid.exe")
#
##	# BUILD version
##	var temp_path = str(OS.get_executable_path().get_base_dir()) + "/dungeon.txt"
##	var img2grid_path = str(OS.get_executable_path().get_base_dir()) + "/PhotoToGrid.exe"
#
#	var file = File.new()
#	if file.file_exists(temp_path):
#		var file_remove = Directory.new()
#		file_remove.remove(temp_path)
#
#	OS.shell_open(img2grid_path)
#
#	var file2 = File.new()
#
#	while !file2.file_exists(temp_path):
#		continue
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	get_tree().change_scene("res://Menu/Menu.tscn")
