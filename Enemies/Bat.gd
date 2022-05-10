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
var path = []
var nav = null
onready var room = get_tree().current_scene

func check_enemy_numbers():
	var enemy_number = (get_tree().get_nodes_in_group("Enemy").size())
	if enemy_number <= 1:
		get_tree().change_scene("res://Wizard Pack/WizRoom.tscn")

func _ready():
	player = constants.player
	yield(owner, "ready")
	nav = owner.nav
	randomize()
	
func _physics_process(delta):
	# line2D.global_position = Vector2.ZERO  # for debugging
	if player:
		generate_path()
		navigate()
	move()

func navigate():	# Define the next position to go to
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * speed
		
		# If reached the destination, remove this point from path array
		if global_position == path[0]:
			path.remove(0)
		
func generate_path():	# It's obvious
	if nav != null and player != null:
		path = nav.get_simple_path(global_position, player.global_position, false)
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
	check_enemy_numbers()
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
