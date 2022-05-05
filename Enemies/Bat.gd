extends KinematicBody2D

var dir = Vector2()
var player
var fireball = preload("res://Fireball/Fireball.tscn")
var offset = 20
func _ready():
	player = constants.player
	
func _physics_process(delta):
	dir = get_dir(player)
	move_and_slide(dir * constants.MAX_SPEED / 4)
	
func get_dir(target):
	return (target.position - position).normalized()

func _on_Timer_timeout():
	dir = get_dir(player)
	var f_ball = fireball.instance()
	get_parent().add_child(f_ball)
	f_ball.dir = dir
	f_ball.position = position + dir * offset


func _on_Hurtbox_area_entered(area):
	create_hit_effect()
	queue_free()

const HitEffect = preload("res://Wizard Pack/HitEffectSmall.tscn")
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("Hurtbox/CollisionShape2D").global_position
