extends KinematicBody2D

# Load constants file and scenes
onready var C = constants
var Arrow = preload("res://Player/Arrow.tscn")

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get(C.playback)
onready var animationRoot = animationTree.get("tree_root")


func _ready():
	C.player = self


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_loc = event.position
		

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength(C.right) - Input.get_action_strength(C.left)
	input_vector.y = Input.get_action_strength(C.down) - Input.get_action_strength(C.up)
	input_vector = input_vector.normalized()
	
	var raw_mouse_loc = get_viewport().get_mouse_position()  # absolute pixel location
	var mouse_loc = raw_mouse_loc - Vector2(C.width/2, C.height/2)
	update_animation_blends(mouse_loc)
	
	# Fire the arrow
	if Input.is_action_just_released("i_shoot"):
		animationRoot.get_node("DrawBow").blend_mode = 1
		if animationState.get_current_node() == "HoldBow":
			animationState.travel("Idle")  # don't wait to reset animation state
			var arrow = Arrow.instance()
			get_parent().add_child(arrow)
			arrow.dest = mouse_loc.normalized()
			arrow.look_at(mouse_loc.normalized())  # rotates the sprite
			arrow.position = position + mouse_loc.normalized() * arrow.offset
	
	# Load the arrow
	elif Input.is_action_pressed("i_shoot"):
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
		
	
func update_animation_blends(mouse_loc):
	"""
	Updates all the AnimationTree blends.
	"""
	animationTree.set(C.idleBlend, mouse_loc)
	animationTree.set(C.moveBlend, mouse_loc)
	animationTree.set(C.moveReverseBlend, mouse_loc)
	animationTree.set(C.drawBowBlend, mouse_loc)
	animationTree.set(C.holdBowBlend, mouse_loc)
