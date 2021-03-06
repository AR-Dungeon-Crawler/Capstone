extends KinematicBody2D

var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var random_num = 0
var charge_count = 0
var countDelta = 0
var stats = StatsWizard
var mana = 59
var powerups = ['power', 'mana', 'movespeed']
var state = MOVE	# Default State

# Load constants file and scene assets.
onready var C = constants
var charge = preload("res://Effects/SingleCharge.tscn")
var release = preload("res://Effects/Release.tscn")
const HitEffect = preload("res://Effects/HitEffect.tscn")

## Node references
onready var animationTree = $AnimationTreeE
onready var animationPlayer = $AnimationPlayerE
onready var effectPlayer = get_parent().get_node("Camera2D/CanvasLayer/ColorRect/AnimationPlayer")
onready var manabar = get_parent().get_node("Camera2D/WizardUI/ManaFull")
onready var powerCount = get_parent().get_node("Camera2D/WizardUI/PowerCt")
onready var speedCount = get_parent().get_node("Camera2D/WizardUI/BootCt")
onready var bonusCount = get_parent().get_node("Camera2D/WizardUI/BonusCt")
onready var hurtbox = $HurtBoxE


func _ready():
	stats.connect("no_health", self, "death")
	

######################### State Machine #########################

##### States #####

enum {
	MOVE,
	HURT,
	ATTACK,
	DYING,
	CHARGE,
	CAST,
	REPEL
}


func _physics_process(delta):
	
##### State Processes #####
	
	match state:
		MOVE:
			move_state(delta)
			
		HURT:
			hurt_state(delta)
			
		ATTACK:
			attack_state(delta)
			
		DYING:
			dying_state(delta)
			
		CHARGE:
			charge_state(delta)
			
		CAST:
			cast_state(delta)
			
		REPEL:
			cast_repel(delta)
			
	# Charge levels and mana management.	
	if state == CHARGE:
		# Drain mana while in charge state.
		mana -= (delta * 35) - (C.wizManaBonus * delta)
		# Mana does not go lower than 0.
		if mana <0:
			mana = 0
		# Count delta for time it takes for each charge to appear.
		countDelta += delta
		if charge_count == 0:
			if countDelta > 0.25 - (0.05 * (C.wizPower/4)):
				countDelta = 0
				add_charge()
		if countDelta > 0.55 - (0.05 * (C.wizPower/4)):
			countDelta = 0
			add_charge()
		# Smooth transition to MOVE state when releasing spacebar.
		if Input.is_action_pressed("space") or Input.is_action_pressed("right_mouse"):
			state = CHARGE
		else:
			countDelta = 0
			state = MOVE
			
	# Update UI Call	
	update_UI(delta)
	

##### State Functions #####
			
func add_charge():
	"""
	Adds charge to Wizard based on Wizard's powerup.
	"""
	if mana <= 1:
		state = MOVE
		return
	if charge_count >= C.wizPower:
		charge_count = C.wizPower
	if charge_count < C.wizPower:
		var charged = charge.instance()
		self.add_child(charged)
		rng.randomize()
		random_num = rng.randi_range(0, 1)
		# Randomize if the charge swirls around the front or the back of Wizard sprite.
		if random_num == 0:
			charged.z_index = 0
		if random_num == 1:
			charged.z_index = 3
		charged.global_position = self.global_position
	charge_count += 1
	
	
func cast_repel(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Repel")
	effectPlayer.play("shockwave")
			
			
func cast_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("QuickCast")
			
			
func dying_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Death")
			
			
func hurt_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Hurt")	
	
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Attack")
	
	
func charge_state(delta):
	velocity = Vector2.ZERO
	animationPlayer.play("Charge")
	
	
func move_state(delta):
	# Make sure hitboxes are deactivated on movement.
	$HitBoxPivotE/HitBoxE/HitCollisionShape2DE.disabled = true
	$HitBoxPivotE/HitBox2E/LHitCollisionShape2DE.disabled = true
	# Directional movement.
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		# Flip sprite appropriately for left or right movement.
		if input_vector.x > 0 or input_vector.y > 0:
			animationPlayer.play("RunRight")
			$SpriteE.flip_h = false
		else:
			animationPlayer.play("RunRight")
			$SpriteE.flip_h = true
		velocity += input_vector * C.wizACCEL * delta
		velocity = velocity.clamped(C.wizMAX_SPEED * delta)
	else:
		# Idle animation.
		animationPlayer.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, C.wizFRICTION * delta)
		
	# State on pressed spacebar is CHARGE.
	if Input.is_action_pressed("space") or Input.is_action_pressed("right_mouse"):
		if mana <= 1:
			return
		state = CHARGE
	
	# State on released spacebar is MOVE.
	if Input.is_action_just_released("space") or Input.is_action_just_released("right_mouse"):
		state = MOVE
	
	# State on pressed 'enter' key is CAST.
	if Input.is_action_just_pressed("enter") or Input.is_action_just_pressed("i_shoot"):
		state = CAST
		# Don't cast anything if not enough charges.
		if charge_count < 1:
			return
		# If cast is successful, remove the used charges.
		var clear_charges = get_tree().get_nodes_in_group("charge")
		for singles in clear_charges:
			singles.queue_free()
		# Cast the spell and instance the animation.
		var released = release.instance()
		self.add_child(released)
		# Based on charge count, the scale and effect of the released spell increases.
		if charge_count == 1:
			# More stars in the animation as spell is released, based on charges.
			released.get_node("Charge").amount = 1
		elif charge_count < 4 and charge_count > 1:
			released.get_node("Charge").amount = 3 * charge_count
		elif charge_count >=4:
			released.get_node("Charge").amount = 15 * charge_count
		# Adjust the scale size of the spell based on charge count.
		released.scale = Vector2((0.20 + (charge_count * 0.1)), (0.20 + (charge_count * 0.1)))
		released.global_position = self.global_position
		# Reset charge count to 0.
		charge_count = 0
	
	# State on pressed 'right alt' key is REPEL.
	if Input.is_action_just_pressed("r_alt") or Input.is_action_just_pressed("middle_mouse"):
		# Need at least this much mana to cast REPEL.
		if mana < 20:
			return
		else:
			mana -= 20
			state = REPEL
	
	move_and_slide(velocity * C.wizMAX_SPEED)
	
######################### End State Machine #########################


#################### Functions Called in Animation ####################

func death_animation_finished():
	# Reset all stats to default values after death.
	get_tree().change_scene("res://Menu/EndGameWizard.tscn")
	C.wizManaBonus = 0
	C.wizPower = 3
	C.wizSpeed = 0
	C.wizACCEL = 500
	C.wizMAX_SPEED = 45
	C.wizFRICTION = 500


func cast_repel_middle():
	# Create the pushback and fireball removal effect.
	var enemies = (get_tree().get_nodes_in_group("Enemy"))
	for enemy in enemies:
		enemy.pushback(self.position)
	# Remove fireballs.
	var fireballs = (get_tree().get_nodes_in_group("Fireball"))
	for ball in fireballs:
		ball.queue_free()
		
		
func cast_animation_finished():
	state = MOVE
	
	
func attack_animation_finished():
	state = MOVE
	$HitBoxPivotE/HitBoxE/HitCollisionShape2DE.disabled = true
	
	
func hurt_antimation_finished():
	state = MOVE
	$HitBoxPivotE/HitBoxE/HitCollisionShape2DE.disabled = true
	
	
func left_attack_box_on():
	if $SpriteE.flip_h == true:
		$HitBoxPivotE/HitBox2E/LHitCollisionShape2DE.disabled = false
		$HitBoxPivotE/HitBoxE/HitCollisionShape2DE.disabled = true
	
	
func left_attack_box_off():
	$HitBoxPivotE/HitBox2E/LHitCollisionShape2DE.disabled = true


#################### Death and Damage ####################
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("HurtBoxE/HurtCollisionShape2DE").global_position


func _on_HurtBox_area_entered(area):
	create_hit_effect()
	hurtbox.start_invincibility(1)
	if stats.health <= 1:
		stats.health -= 1
		return
	stats.health -= 1
	state = HURT


func death():
	state = DYING


func _on_Hitbox_area_entered(area):
	"""
	Powerup chest entered Wizard's hitbox, grant random powerup.
	"""
	if area.get_parent().is_in_group('Chest'):
		var power = powerups[randi() % powerups.size()]
		if power == 'power':
			C.wizPower += 1
		if power == 'movespeed':
			C.wizSpeed += 1
			adjust_speed()
		if power == 'mana':
			C.wizManaBonus += 1
			
			
func adjust_speed():
	"""
	Diminishing returns for movement speed bonuses.
	"""
	if C.wizSpeed <= 2:
		C.wizMAX_SPEED = (5 * C.wizSpeed) + C.wizMAX_SPEED
	if C.wizSpeed <= 6:
		C.wizMAX_SPEED = (2 * C.wizSpeed) + C.wizMAX_SPEED
	else:
		C.wizMAX_SPEED = 2 + C.wizMAX_SPEED
	if C.speed < 10:
		C.wizACCEL = (500 * C.wizSpeed) + C.wizACCEL
		C.wizFRICTION = (500 * C.wizSpeed) + C.wizFRICTION
		
		
func update_UI(delta):
	"""
	Update the mana bar, and powerups UI.
	Maximum mana is 59.
	"""
	manabar.rect_size.x = mana
	if mana >= 59:
		mana = 59
	# Mana recharge rate.
	mana += (delta * 13) + ((C.wizManaBonus/3) * delta)
	if mana >= 59:
		mana = 59

	powerCount.text = "x" + str(C.wizPower)
	speedCount.text = "x" + str(C.wizSpeed)
	bonusCount.text = "x" + str(C.wizManaBonus)
