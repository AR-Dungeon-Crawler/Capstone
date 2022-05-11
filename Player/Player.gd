extends KinematicBody2D

# Load constants file and scenes
onready var C = constants
var Arrow = preload("res://Player/Arrow.tscn")

var velocity = Vector2.ZERO
export var spread : float = 1
export var attack_cooldown : float = 0.5
var added_spread : float = 0.1
var powerups = ['arrow', 'accuracy', 'movespeed']
var stats = StatsPlayer

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var stopwatch = $Stopwatch
onready var cooldown = $Cooldown
onready var animationState = animationTree.get(C.playback)
onready var animationRoot = animationTree.get("tree_root")
onready var hurtbox = $Hurtbox
onready var chargebar = get_parent().get_node("Camera2D/HealthUI/ChargeFull")
onready var arrowCount = get_parent().get_node("Camera2D/HealthUI/ArrowCt")
onready var speedCount = get_parent().get_node("Camera2D/HealthUI/BootCt")
onready var accuracyCount = get_parent().get_node("Camera2D/HealthUI/BullseyeCt")

var countDelta = 0

func _ready():
	stats.connect("no_health", self, "queue_free")
	randomize()
	C.player = self


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_loc = event.position
		

func _physics_process(delta):
	update_UI()
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength(C.right) - Input.get_action_strength(C.left)
	input_vector.y = Input.get_action_strength(C.down) - Input.get_action_strength(C.up)
	input_vector = input_vector.normalized()
	
	var raw_mouse_loc = get_viewport().get_mouse_position()  # absolute pixel location
	var mouse_loc = raw_mouse_loc - Vector2(C.width/2, C.height/2)
	update_animation_blends(mouse_loc)
	
	# Fire the arrow
	if Input.is_action_just_released("i_shoot"):
		# Start cooldown on firing
		if cooldown.time_elapsed < attack_cooldown:  # an arrow can only be fired twice a second
			countDelta = 0
			return
		cooldown.start_stopwatch()  # resets the cooldown timer
		
		# Check how long bow was drawn for accuracy
		stopwatch.stop_stopwatch()
		var shot_spread = spread - stopwatch.time_elapsed * 2  # speeds up the accuracy calibration
		if shot_spread < 0:
			shot_spread = 0
			
		# Manually adjust some animation attributes (needed to fix some graphical issues)
		animationRoot.get_node("DrawBow").blend_mode = 1
		animationState.travel("Idle")  # don't wait to reset animation state
		
		# Create arrow entities and fire toward mouse
		fire_arrows(mouse_loc, shot_spread)
	
	# Load the arrow
	elif Input.is_action_pressed("i_shoot"):
		countDelta += delta
		if countDelta > 0.6:
			countDelta = 1
		if stopwatch.running == false:
			stopwatch.start_stopwatch()
		var current_node = animationState.get_current_node()
		# Only play draw animation if not currently drawing (prevents unwanted animation loops)
		if current_node == "Move" or current_node == "Idle":
			animationState.travel("DrawBow")
		# Come to a stop when starting to draw
		velocity = velocity.move_toward(Vector2.ZERO, C.FRICTION * delta)
	
	# Move
	elif input_vector != Vector2.ZERO:
		animationState.travel("Move")
		velocity = velocity.move_toward(input_vector * C.MAX_SPEED, C.ACCELERATION * delta)
		
	# Idle
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, C.FRICTION * delta)
		
	move_and_slide(velocity)
	
	
func fire_arrows(mouse_loc, shot_spread):
	#countDelta makes arrow shoot faster if mouse is held longer.
	if countDelta > 0.6:
		countDelta = 1
	for i in range(C.arrows):
			var arrow = Arrow.instance()
			get_parent().add_child(arrow)
			arrow.dest = mouse_loc.normalized().rotated(
				# Each additional arrow has increased spread range
				rand_range(-shot_spread - added_spread * i, shot_spread + added_spread * i)
				)
			arrow.SPEED = arrow.SPEED * (countDelta)
			arrow.look_at(arrow.dest)  # rotates the sprite
			arrow.position = position + arrow.dest * arrow.offset
	countDelta = 0
		
	
func update_animation_blends(mouse_loc):
	"""
	Updates all the AnimationTree blends.
	"""
	animationTree.set(C.idleBlend, mouse_loc)
	animationTree.set(C.moveBlend, mouse_loc)
	animationTree.set(C.moveReverseBlend, mouse_loc)
	animationTree.set(C.drawBowBlend, mouse_loc)
	animationTree.set(C.holdBowBlend, mouse_loc)

const HitEffect = preload("res://Wizard Pack/HitEffect.tscn")
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("Hitbox/CollisionShape2D").global_position

func _on_Hitbox_area_entered(area):
	if area.get_parent().is_in_group('Chest'):
		var power = powerups[randi() % powerups.size()]
		if power == 'arrow':
			print('arrow')
			C.arrows += 1
		if power == 'movespeed':
			print('maxspeed')
			C.MAX_SPEED *= 1.2
			C.ACCELERATION *= 1.2
			C.speed += 1
		if power == 'accuracy':
			print('accuracy')
			C.accuracy += 1
			spread -= 0.1

func _on_Hurtbox_area_entered(area):
	hurtbox.start_invincibility(0.5)
	create_hit_effect()
	stats.health -= 1

func update_UI():
	chargebar.rect_size.x = countDelta * 59
	if countDelta == 1:
		chargebar.rect_size.x = 59
	arrowCount.text = "x" + str(C.arrows)
	speedCount.text = "x" + str(C.speed)
	accuracyCount.text = "x" + str(C.accuracy)
