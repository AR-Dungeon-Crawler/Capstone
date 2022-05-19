extends Area2D

const SPEED = 100
var dir = Vector2()


func _physics_process(delta):
	translate(dir * SPEED * delta)


func _on_Timer_timeout():
	queue_free()


func _on_Fireball_body_entered(body):
	if body.name == "Player":
		queue_free()


func _on_Fireball_area_entered(area):
	if area.name == "PlayerHurtbox":
		queue_free()
