extends Control

func _on_Back_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")


func _on_Mechanics_pressed():
	get_tree().change_scene("res://Menu/Instructions2.tscn")
