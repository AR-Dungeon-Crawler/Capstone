extends Control

func _ready():

	# TEST version.
	var temp_path = ProjectSettings.globalize_path("res://dungeon.txt")
	var img2grid_path = ProjectSettings.globalize_path("res://PhotoToGrid.exe")
#
##	# BUILD version
##	var temp_path = str(OS.get_executable_path().get_base_dir()) + "/dungeon.txt"
##	var img2grid_path = str(OS.get_executable_path().get_base_dir()) + "/PhotoToGrid.exe"

	# Check for and remove any old dungeon.txt files.
	var file = File.new()
	if file.file_exists(temp_path):
		var file_remove = Directory.new()
		file_remove.remove(temp_path)

	# Run Python map generation script.
	OS.shell_open(img2grid_path)

	# Continue when new dungeon.txt is found.
	var file2 = File.new()
	while !file2.file_exists(temp_path):
		continue
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	# Run main menu scene.
	get_tree().change_scene("res://Menu/Menu.tscn")
