extends Control


func _on_MainMenu_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")


func _on_PlayAgainWiz_pressed():
	get_tree().change_scene("res://World/PlayWizardRoom.tscn")
