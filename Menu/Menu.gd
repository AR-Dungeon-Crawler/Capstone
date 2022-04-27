extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_StartButton_pressed():
	get_tree().change_scene("res://World/Room.tscn")


func _on_Instructions_pressed():
	get_tree().change_scene("res://Menu/Instructions.tscn")
