extends KinematicBody2D

onready var C = constants

var ACCEL = 500
var MAX_SPEED = 45
var FRICTION = 500

var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var random_num = 0
var charge_count = 0
var countDelta = 0
var stats = StatsWizard
var mana = 59
var powerups = ['power', 'mana', 'movespeed']

onready var animationTree = $AnimationTreeE
onready var animationPlayer = $AnimationPlayerE
var charge = preload("res://Wizard Pack/SingleCharge.tscn")
var release = preload("res://Wizard Pack/Release.tscn")
onready var manabar = get_parent().get_node("Camera2D/WizardUI/ManaFull")
onready var powerCount = get_parent().get_node("Camera2D/WizardUI/PowerCt")
onready var speedCount = get_parent().get_node("Camera2D/WizardUI/BootCt")
onready var bonusCount = get_parent().get_node("Camera2D/WizardUI/BonusCt")

enum {
	MOVE,
	HURT,
	ATTACK,
	DYING,
	CHARGE,
	CAST
}

var state = MOVE

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	stats.connect("no_health", self, "death")

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
			
		CHARGE:
			charge_state(delta)
			
		CAST:
			cast_state(delta)
			
	update_UI(delta)
	
	if state == CHARGE:
		mana -= (delta * 35) - (C.wizManaBonus * delta)
		if mana <0:
			mana = 0
		countDelta += delta
		if charge_count == 0:
			if countDelta > 0.4 - (0.05 * (C.wizPower/4)):
				countDelta = 0
				add_charge()
		if countDelta > 0.7 - (0.05 * (C.wizPower/4)):
			countDelta = 0
			add_charge()
		if Input.is_action_pressed("space"):
			state = CHARGE
		else:
			countDelta = 0
			state = MOVE
			
func add_charge():
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
		if random_num == 0:
			charged.z_index = 0
		if random_num == 1:
			charged.z_index = 3
		charged.global_position = self.global_position
	charge_count += 1
			
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
	$HitBoxPivotE/HitBoxE/HitCollisionShape2DE.disabled = true
	$HitBoxPivotE/HitBox2E/LHitCollisionShape2DE.disabled = true
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		
		if input_vector.x > 0 or input_vector.y > 0:
			animationPlayer.play("RunRight")
			$SpriteE.flip_h = false
		else:
			animationPlayer.play("RunRight")
			$SpriteE.flip_h = true
		velocity += input_vector * ACCEL * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		animationPlayer.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if Input.is_action_pressed("space"):
		if mana <= 1:
			return
		state = CHARGE
		
	if Input.is_action_just_released("space"):
		state = MOVE
		
	if Input.is_action_just_pressed("enter"):
		state = CAST
		if charge_count < 1:
			return
		var clear_charges = get_tree().get_nodes_in_group("charge")
		for singles in clear_charges:
			singles.queue_free()
		var released = release.instance()
		self.add_child(released)
		released.get_node("Charge").amount = 15 * charge_count
		released.scale = Vector2((0.20 + (charge_count * 0.1)), (0.20 + (charge_count * 0.1)))
		released.global_position = self.global_position
		charge_count = 0
		
	
	move_and_slide(velocity * MAX_SPEED)
	
func death_animation_finished():
	get_tree().change_scene("res://Menu/EndGameWizard.tscn")
		
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
	
const HitEffect = preload("res://Wizard Pack/HitEffect.tscn")
	
func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	hitEffect.global_position = get_node("HurtBoxE/HurtCollisionShape2DE").global_position

func _on_HurtBox_area_entered(area):
	create_hit_effect()
	if stats.health <= 1:
		stats.health -= 1
		return
	stats.health -= 1
	state = HURT

func death():
	state = DYING
	
func free():
	queue_free()


func _on_Hitbox_area_entered(area):
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
		MAX_SPEED = (5 * C.wizSpeed) + MAX_SPEED
	if C.wizSpeed <= 6:
		MAX_SPEED = (2 * C.wizSpeed) + MAX_SPEED
	else:
		MAX_SPEED = 2 + MAX_SPEED
	if C.speed < 10:
		ACCEL = (500 * C.wizSpeed) + ACCEL
		FRICTION = (500 * C.wizSpeed) + FRICTION
		
func update_UI(delta):
	manabar.rect_size.x = mana
	if mana >= 59:
		mana = 59
	mana += (delta * 15) + ((C.wizManaBonus/3) * delta)
	if mana >= 59:
		mana = 59

	powerCount.text = "x" + str(C.wizPower)
	speedCount.text = "x" + str(C.wizSpeed)
	bonusCount.text = "x" + str(C.wizManaBonus)
