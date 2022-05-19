extends Area2D

var direction = Vector2.ZERO
var SPEED = 80
var velocity = Vector2.ZERO

func _physics_process(delta):
	var dest = Vector2(direction)
	global_position += dest * SPEED * delta
	
func _on_Timer_timeout():
	queue_free()
