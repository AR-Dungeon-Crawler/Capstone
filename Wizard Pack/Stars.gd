extends Area2D

var direction = Vector2.ZERO
var speed = 150
var velocity = Vector2.ZERO

func _physics_process(delta):
	var dest = Vector2(direction)
	global_position += dest * speed * delta
	
	
func _on_Timer_timeout():
	queue_free()
	



func _on_Stars_area_entered(area):
	queue_free()


func _on_Stars_body_entered(body):
	queue_free()
