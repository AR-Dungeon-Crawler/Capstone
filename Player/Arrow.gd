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


func _on_Arrow_area_entered(area):
	queue_free()


func _on_Arrow_body_entered(body):
	queue_free()


func _on_Arrow_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	queue_free()


func _on_Hitbox_area_entered(area):
	queue_free()
