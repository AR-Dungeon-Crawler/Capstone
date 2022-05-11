extends KinematicBody2D

# onready var line2D = $Line2D
export var speed : int = 20
export var drop_chance : float = 50
var dir = Vector2()
var player
var fireball = preload("res://Fireball/Fireball.tscn")
var Chest = preload("res://World/Chest.tscn")
var offset = 20
var velocity = Vector2.ZERO
var path: Array = []
var levelNavigation: Navigation2D = null
onready var room = get_tree().current_scene

func _ready():
	player = constants.player
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
#	yield(owner, "ready")
	randomize()
	
func _physics_process(delta):
	# line2D.global_position = Vector2.ZERO  # for debugging
	if player and levelNavigation:
		generate_path()
		navigate()
	move()

func navigate():	# Define the next position to go to
	if is_instance_valid(player):
		if path.size() > 0:
			velocity = global_position.direction_to(path[1]) * speed
			
			# If reached the destination, remove this point from path array
			if global_position == path[0]:
				path.pop_front()
		
func generate_path():	# It's obvious
	if !is_instance_valid(player):
		return
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
		# line2D.points = path  # for debugging
		
func move():
	velocity = move_and_slide(velocity, Vector2(0, 0))

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
	# Check if enemy drops a powerup
	if rand_range(0, 100) <= drop_chance:
		var chest = Chest.instance()
		get_parent().add_child(chest)
		chest.position = global_position
	queue_free()
	

const HitEffect = preload("res://Wizard Pack/HitEffectSmall.tscn")
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("Hurtbox/CollisionShape2D").global_position
