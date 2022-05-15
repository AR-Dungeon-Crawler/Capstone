extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_StartButton_pressed():
	get_tree().change_scene("res://Menu/ClassSelection.tscn")

func _on_Instructions_pressed():
	get_tree().change_scene("res://Menu/Instructions.tscn")

func _on_Maze_generation_pressed():
	get_tree().change_scene("res://Maze Generation/Maze.tscn")
