extends Control

var life = 5 setget set_life
var max_life = 5 setget set_max_life

onready var healthUIFull = $HealthFull
onready var healthUIEmpty = $HealthEmpty

func set_life(value):
	life = clamp(value, 0, max_life)
	if healthUIFull != null:
		healthUIFull.rect_size.y = life * 10
	
func set_max_life(value):
	max_life = max(value, 1)
	if healthUIEmpty != null:
		healthUIEmpty.rect_size.y = max_life * 10
	
func _ready():
	self.max_life = StatsWizard.max_health
	self.life = StatsWizard.health
	StatsWizard.connect("health_changed", self, "set_life")
