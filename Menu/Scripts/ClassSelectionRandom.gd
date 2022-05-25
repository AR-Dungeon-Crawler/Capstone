extends Control



func _on_BackRand_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")


func _on_SelectArcherRand_pressed():
	get_tree().change_scene("res://Maze Generation/Maze.tscn")


func _on_SelectWizardRand_pressed():
	get_tree().change_scene("res://Maze Generation/MazeWizard.tscn")
