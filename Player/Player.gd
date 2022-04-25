extends KinematicBody2D

# Load constants file
onready var C = constants

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get(C.playback)

# What does this do? This makes the location of player available globally
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
	
	var mouse_loc = get_viewport().get_mouse_position()
	
	animationTree.set(C.idleBlend, mouse_loc)
	animationTree.set(C.moveBlend, mouse_loc)
	animationTree.set(C.moveReverseBlend, mouse_loc)
	
	if input_vector != Vector2.ZERO:
		animationState.travel("Move")
		velocity = velocity.move_toward(input_vector * C.MAX_SPEED, C.ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, C.FRICTION * delta)
		
	
	
	move_and_slide(velocity)
