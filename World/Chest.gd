extends Node2D

var object_type = 'Chest'

func _on_Area2D_area_entered(area):
	queue_free()
