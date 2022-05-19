extends Node

# Chance for bat to spawn as a super bat
var super_chance : float = 25

# Stat declarations to be udpated with either function below
var bat_type : String
var speed : int
var drop_chance : float  # powerup drop percent chance
var health : int
var fireball_delay = rand_range(0, 3)


func load_bat_stats():
	bat_type = 'normal'
	speed = 20
	drop_chance = 50
	health = 2
	
	
func load_superbat_stats():
	bat_type = 'super'
	speed = 30
	drop_chance = 100
	health = 4
	
