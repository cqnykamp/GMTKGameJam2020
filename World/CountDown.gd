extends Node2D

signal timeout
signal time_reset
signal new_time

const level_start_time = 10
var time = 0
var time_factor = 0

var has_signaled_timeout = false

func _ready():
	$Label.text = str(level_start_time)
	
func _process(delta):
	
	time += time_factor * delta
	
	if time > level_start_time and not has_signaled_timeout:
		emit_signal("timeout")
		has_signaled_timeout = true
		
	elif time < 0 and time_factor != 0:
		emit_signal("time_reset")
		time = 0
		time_factor = 0
		
	if time_factor != 0:
		emit_signal("new_time", time, time_factor)
		pass
		
	if time < level_start_time:
		has_signaled_timeout = false
	
	$Label.text = str(level_start_time - floor(time))


func count_down():
	set_deferred("time_factor", 1)

func count_back_up(new_factor):
	print('setting time factor')
	set_deferred("time_factor", new_factor)
