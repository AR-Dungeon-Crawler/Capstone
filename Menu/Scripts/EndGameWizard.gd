extends Control


func _on_MainMenu_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")


func _on_PlayAgainWiz_pressed():
	get_tree().change_scene("res://World/PlayWizardRoom.tscn")


func _on_PlayAgainWizWin_pressed():
	get_tree().change_scene("res://World/PlayWizardRoom.tscn")

func _on_Random_Maze_pressed():
	get_tree().change_scene("res://Maze Generation/MazeWizard.tscn")

func _on_MainMenuWinWiz_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")




func _on_PlayAgainRanWizWin2_pressed():
	get_tree().change_scene("res://Maze Generation/MazeWizard.tscn")
