extends Control



func _on_Maze_generation_pressed():
	get_tree().change_scene("res://Menu/ClassSelectionRandomMaze.tscn")

func _on_StartButton_pressed():
	get_tree().change_scene("res://Menu/ClassSelection.tscn")
