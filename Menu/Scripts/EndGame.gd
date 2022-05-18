extends Control


func _on_PlayAgain_pressed():
	get_tree().change_scene("res://World/Room.tscn")


func _on_Main_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")
