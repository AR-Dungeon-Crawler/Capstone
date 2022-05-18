extends Label

# Citation for Stopwatch
# https://gamedevbeginner.com/how-to-make-a-timer-in-godot-count-up-down-in-minutes-seconds/#stopwatch
# 5/5/22

var time_elapsed : float = 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	
func start_stopwatch():
	time_elapsed = 0
