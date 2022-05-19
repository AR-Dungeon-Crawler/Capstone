extends Area2D

const SPEED = 300
var dir = Vector2()


func _physics_process(delta):
	translate(dir * SPEED * delta)

func _on_Timer_timeout():
	queue_free()

func _on_Fireball_body_entered(body):
	if body.name == "TileMap" or body.name == "Player":
		queue_free()
