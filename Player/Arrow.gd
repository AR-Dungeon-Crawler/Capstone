# Citation for projectile code concept
# https://kidscancode.org/godot_recipes/2d/2d_shooting/

extends Area2D

var SPEED = 300
var velocity = Vector2.ZERO
var dest = Vector2()
var offset = 10


func _physics_process(delta):
	position += dest * SPEED * delta
	
	
func _on_Timer_timeout():
	queue_free()
