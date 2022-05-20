extends KinematicBody2D


var dir = Vector2()
var velocity = Vector2.ZERO
var path: Array = []
var levelNavigation: Navigation2D = null
onready var player = constants.player  # player being targeted
onready var room = get_tree().current_scene
onready var softCollision = $SoftCollision
onready var sprite = $AnimatedSprite
onready var stats = $StatsBat
onready var fireball_timer = $FireballTimer
var knockback = Vector2.ZERO

# Preloaded .tscn
var fireball = preload("res://Enemies/Bat/Attack/Fireball.tscn")
var Chest = preload("res://World/Chest.tscn")
var DeathSound = preload("res://Music and Sounds/BatDeath.tscn")
var HitSound = preload("res://Music and Sounds/HitSound.tscn")
var HitEffect = preload("res://Effects/HitEffectSmall.tscn")


func _ready():
	
	# Determine power level of bat (normal vs super)
	randomize()
	if rand_range(0, 100) <= stats.super_chance:
		stats.load_superbat_stats()
		sprite.self_modulate = Color(1, 0, 0)
	else:
		stats.load_bat_stats()
		
	# Delay start of fireball attacks
	if stats.bat_type == 'super':
		delay_fireball(stats.fireball_delay)
		
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
#	yield(owner, "ready")


func get_dir(target):
	return (target.position - position).normalized()


func _on_FireballTimer_timeout():
	shoot_fireball()


#################### Navigation and Pathfinding ####################

func _physics_process(delta):
	# line2D.global_position = Vector2.ZERO  # for debugging
	if player and levelNavigation:
		generate_path()
		navigate()
	move()
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)


# Define the next position to go to
func navigate():	
	if is_instance_valid(player):
		if path.size() > 0:
			velocity = global_position.direction_to(path[1]) * stats.speed
			
			# If reached the destination, remove this point from path array
			if global_position == path[0]:
				path.pop_front()
		
		
func generate_path():
	if !is_instance_valid(player):
		return
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
		# line2D.points = path  # for debugging
		
		
func move():
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector()
	velocity = move_and_slide(velocity, Vector2(0, 0))
	
func pushback(target):
	knockback = -(target - position) * 3
	apply_slow()
	
func apply_slow():
	var speedTimer = Timer.new()
	speedTimer.set_one_shot(true)
	speedTimer.set_wait_time(2)
	speedTimer.connect("timeout", self, "_restore_speed")
	add_child(speedTimer)
	speedTimer.start()
	stats.speed -= 10

func _restore_speed():
	if is_instance_valid(self):
		stats.speed += 10

	

#################### Death and Damage ####################

func _on_Hurtbox_area_entered(area):
	create_hit_effect()
	stats.health -= 1
	if stats.health >= 1:
		get_parent().add_child(HitSound.instance())
	elif stats.health <= 0:
		# Check if enemy drops a powerup
		if rand_range(0, 100) <= stats.drop_chance:
			var chest = Chest.instance()
			# Call deferred for add child to get rid of physics flushing queries error.
			get_parent().call_deferred("add_child", chest)
			chest.position = global_position
		get_parent().add_child(DeathSound.instance())
		queue_free()
	
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("Hurtbox/CollisionShape2D").global_position
	
	
#################### Attacking (Fireball) ####################

# Fireball spawns 15 pixels above center of bat sprite
var fireball_offset = Vector2(0, 15)


# Set a delay so fireballs fire at different times
func delay_fireball(time):
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_timer_callback")
	add_child(timer)
	timer.start(time)
	
	
func _timer_callback():
	fireball_timer.start()


func shoot_fireball():
	dir = get_fireball_dir(player)
	var f_ball = fireball.instance()
	get_parent().add_child(f_ball)
	f_ball.position = position + dir - fireball_offset
	f_ball.dir = dir * .75
	

func get_fireball_dir(target):
	# Need to remove the offset when getting target direction
	return (target.position - position + fireball_offset).normalized()
