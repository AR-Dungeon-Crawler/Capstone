extends KinematicBody2D

var dir = Vector2()
var player

func _ready():
	player = constants.player
	
func _physics_process(delta):
	dir = get_dir(player)
	move_and_slide(dir * constants.MAX_SPEED / 2)
	
func get_dir(target):
	return (target.position - position).normalized()
