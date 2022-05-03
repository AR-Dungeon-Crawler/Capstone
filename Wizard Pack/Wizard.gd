extends KinematicBody2D

const ACCEL = 40
const MAX_SPEED = 100
const FRICTION = 80

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var stats = $StatsP

enum {
	MOVE,
	HURT,
	ATTACK,
	DYING
}

var state = MOVE

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	match state:
		MOVE:
			move_state(delta)
			
		HURT:
			hurt_state(delta)
			
		ATTACK:
			attack_state(delta)
			
		DYING:
			dying_state(delta)
			
func dying_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Death")
			
func hurt_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Hurt")
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Attack")
	
func move_state(delta):
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = true
#	var input_vector = Vector2.ZERO
#	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
#	input_vector = input_vector.normalized()
#
#	if input_vector != Vector2.ZERO:
#
#		if input_vector.x > 0 or input_vector.y > 0:
#			animationPlayer.play("RunRight")
#			$Sprite.flip_h = false
#		else:
#			animationPlayer.play("RunRight")
#			$Sprite.flip_h = true
#		velocity += input_vector * ACCEL * delta
#		velocity = velocity.clamped(MAX_SPEED * delta)
#	else:
	animationPlayer.play("Idle")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
#
#	if Input.is_action_just_pressed("i_shoot"):
#		state = ATTACK
	
	move_and_slide(velocity * MAX_SPEED)
	
func attack_animation_finished():
	state = MOVE
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	
func hurt_antimation_finished():
	state = MOVE
	$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	
func left_attack_box_on():
	if $Sprite.flip_h == true:
		$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = false
		$HitBoxPivot/HitBoxP/HitCollisionShape2D.disabled = true
	
func left_attack_box_off():
	$HitBoxPivot/HitBox2/LHitCollisionShape2D.disabled = true

const HitEffect = preload("res://Wizard Pack/HitEffect.tscn")
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = global_position

func _on_HurtBox_area_entered(area):
	create_hit_effect()
	if stats.health <= 1:
		stats.health -= 1
		return
	stats.health -= 1
	state = HURT

func _on_StatsP_no_health():
	state = DYING
	
func free():
	queue_free()
	
