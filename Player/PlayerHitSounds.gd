extends AudioStreamPlayer


# Citatation for dynamic loading of sound
# Adapted from
# https://www.reddit.com/r/godot/comments/b7otmb/how_do_i_play_multiple_sounds_at_the_same_time/
var Hit1 = load("res://Music and Sounds/playerhit1.ogg")
var Hit2 = load("res://Music and Sounds/playerhit2.ogg")
var Hit3 = load("res://Music and Sounds/playerhit3.ogg")
var Hit4 = load("res://Music and Sounds/playerhit4.ogg")
var Hit5 = load("res://Music and Sounds/playerhit5.ogg")

func play_sound(sound_name):
	# If statements needed to fix audio glitch from changing to same file
	match(sound_name):
		'hit1':
			if stream != Hit1:
				stream = Hit1
		'hit2':
			if stream != Hit2:
				stream = Hit2
		'hit3':
			if stream != Hit3:
				stream = Hit3
		'hit4':
			if stream != Hit4:
				stream = Hit4
		'hit5':
			if stream != Hit5:
				stream = Hit5
	
	play()
