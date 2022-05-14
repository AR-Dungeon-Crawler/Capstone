extends Control

func _on_PlayAgain_pressed():
	get_tree().change_scene("res://World/Room.tscn")


func _on_QuitGame_pressed():
	get_tree().quit()
