extends KinematicBody2D

var stagger = 15	# Hits taken before staggered animation is triggered.
var hits_to_vortex = 30		# Hits taken before vortex attack phase starts.
var rng = RandomNumberGenerator.new()
var random_num = 0
var velocity = Vector2.ZERO
var last_direction = "L"
var state = MOVE_L
var lock_state = false

# Movement Constants
const ACCEL = 100
const MAX_SPEED = 100
const FRICTION = 40

# Node references
onready var animationPlayer = $AnimationPlayer
onready var stats = $StatsP
onready var player = get_parent().get_node("Player")

# Preload Assets
var HitSound = preload("res://Music and Sounds/HitSound.tscn")
var HitEffect = preload("res://Effects/HitEffect.tscn")
var vortex = preload("res://Effects/VortexArea.tscn")
var stars = preload("res://Effects/Stars.tscn")
var stars_sound = preload("res://Music and Sounds/BossStarAttackSound.tscn")
var vortex_sound = preload("res://Music and Sounds/BossVortexAttackSound.tscn")


######################### State Machine #########################

##### States #####

enum {
	IDLE,
	MOVE_L,
	MOVE_R,
	HURT,
	ATTACK,
	DYING,
	STAFF
}


##### State Processes #####

func _physics_process(delta):
	
	match state:
		IDLE:
			idle_state(delta)
			
		MOVE_L:
			move_state_L(delta)
			
		MOVE_R:
			move_state_R(delta)
			
		HURT:
			hurt_state(delta)
			
		ATTACK:
			attack_state(delta)
			
		DYING:
			dying_state(delta)
			
		STAFF:
			staff_attack(delta)
			
			
##### State Functions #####
			
func dying_state(delta):
	lock_state = true
	velocity = Vector2.ZERO
	animationPlayer.play("Death")
			
			
func hurt_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Hurt")
	
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Attack")
	
	
func idle_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Idle")
	rng.randomize()
	random_num = rng.randi_range(0, 1)
	yield(get_tree().create_timer(0.5), "timeout")
	if state == IDLE and lock_state == false:
		# Randomize Left and Right movement.
		if random_num == 0:
			state = MOVE_R
		if random_num == 1:
			state = MOVE_L
			
			
func staff_attack(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Staff")
	
	
func move_state_L(delta):
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = true
	# Flip animation for Left movement.
	$Sprite.flip_h = true
	animationPlayer.play("RunRight")
	var direction = Vector2(-100, 0).normalized()
	# Execute movement.
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCEL * delta)
	move_and_slide(velocity)
	# Move to next state after timer.
	yield(get_tree().create_timer(1.5), "timeout")
	if state == MOVE_L and lock_state == false:
		state = ATTACK
		
		
func move_state_R(delta):
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = true
	# Undo any animation flips for right movement.
	$Sprite.flip_h = false
	animationPlayer.play("RunRight")
	var direction = Vector2(100, 0).normalized()
	# Execute movement.
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCEL * delta)
	move_and_slide(velocity)
	# Move to next state after timer.
	yield(get_tree().create_timer(1.5), "timeout")
	if state == MOVE_R and lock_state == false:
		state = ATTACK
		
		
######################### End State Machine #########################
		
		
#################### Functions Called in Animation ####################
	
func attack_animation_finished():
	state = IDLE
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	
	
func hurt_antimation_finished():
	if hits_to_vortex <= 0:
		state = STAFF
	elif stats.health <= 0:
		state = DYING
	else:
		state = IDLE
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	
	
func left_attack_box_on():
	if $Sprite.flip_h == true:
		$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = false
		$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	
	
func left_attack_box_off():
	$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = true


#################### Attacks and Spells ####################
"""
Direction arrays for creating multiple star assets for main attack.
"""
var direction_array = \
	[ \
	Vector2(0,1),
	Vector2(0,-1),
	Vector2(-1,0),
	Vector2(1,0) \
	]
var diagonal_array = \
	[ \
	Vector2(1,1),
	Vector2(1,-1),
	Vector2(-1,1),
	Vector2(-1,-1),
	Vector2(1,0.5),
	Vector2(0.5, 1),
	Vector2(-0.5,1),
	Vector2(-1, 0.5),
	Vector2(-1,-0.5),
	Vector2(-0.5,-1),
	Vector2(0.5,-1),
	Vector2(1,0.5) \
	]
	
	
func create_stars():
	# 'spawn' variable notes the position where the stars should spawn from.
	var spawn
	get_parent().add_child(stars_sound.instance())
	# Flip sprite depending on left or right movement.
	if $Sprite.flip_h == true:
		spawn = get_node("HitBoxPivot/HitBox2/LHitCollisionShape2D").global_position
	if $Sprite.flip_h == false:
		spawn = get_node("HitBoxPivot/HitBoxP/HitCollisionShape2D").global_position
	# Firing up, down, left, and right direction stars.
	for vect in direction_array:
		var star = stars.instance()
		get_tree().current_scene.add_child(star)
		star.global_position = spawn
		star.direction = vect
	# Firing diagonal stars.
	for vect in diagonal_array:
		var star = stars.instance()
		get_tree().current_scene.add_child(star)
		star.global_position = spawn
		star.speed = 150
		star.direction = vect
	

func create_vortex():
	var vortex1 = vortex.instance()
	get_tree().current_scene.add_child(vortex1)
	get_parent().add_child(vortex_sound.instance())
	# Flip sprite depending on left or right movement.
	if $Sprite.flip_h == true:
		vortex1.global_position = get_node("HitBoxPivot/HitBox2/Position2D").global_position
	if $Sprite.flip_h == false:
		vortex1.global_position = get_node("HitBoxPivot/HitBoxP/Position2D").global_position
	
	# Check to make sure that player is not killed.
	if !is_instance_valid(player):
		return
	
	# Player direction to fire vortex.
	var rotation = vortex1.global_position.direction_to(player.global_position)
	vortex1.direction = rotation
	

#################### Death and Damage ####################

func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("HurtBox/HurtCollisionShape2D").global_position


func _on_HurtBox_area_entered(area):
	"""
	'stagger' must be depleted before true damage to healh takes place,
	and 'stagger' will replenish after true damage.
	When true damage is done, stagger animation will play.
	"""
	create_hit_effect()
	if stats.health >= 2:
		get_parent().add_child(HitSound.instance())
	stagger -= 1
	hits_to_vortex -= 1
	if stagger <= 0:
		stagger = 18
		if stats.health <= 1:
			stats.health -= 1
			return
		stats.health -= 1
		state = HURT
	elif hits_to_vortex <= 0 and stagger <= 0:
		stagger = 18
		if stats.health <=1:
			stats.health -= 1
			return
		state = HURT
	elif hits_to_vortex <= 0 and stagger >= 1:
		if stats.health <=1:
			stats.health -= 1
			return
		state = STAFF
		

func _on_StatsP_no_health():
	state = DYING
	
func free():
	queue_free()
	
func load_win_scene():
	get_tree().change_scene("res://Menu/WinGameDefault.tscn")
