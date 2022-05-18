extends Control


func _on_SelectArcher_pressed():
	get_tree().change_scene("res://World/Room.tscn")


func _on_SelectWizard_pressed():
	get_tree().change_scene("res://Wizard Pack/PlayWizardRoom.tscn")


func _on_Back_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")
