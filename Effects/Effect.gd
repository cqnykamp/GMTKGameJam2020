extends Node2D

signal at_end
signal at_start

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "send_end_signal")
	
func send_end_signal(anim_name):
	emit_signal("at_end")

func go_to_end():
	$AnimationPlayer.play("Run", -1, 0, true)

func get_animation_length():
	return $AnimationPlayer.get_animation("Run").length
	
func set_animation_moment(timestamp):
	$AnimationPlayer.play("Run")
	$AnimationPlayer.advance(timestamp)
	$AnimationPlayer.stop(false)
	print(timestamp)
	
func play(time_factor):
	$AnimationPlayer.play("Run", -1, time_factor)
	
func stop():
	$AnimationPlayer.stop(false)
	
func is_playing():
	return $AnimationPlayer.is_playing()

#func play_forward_and_destroy():
#	$DestroyTimer.start(get_animation_length())
#	$AnimationPlayer.play("Run")
##	emit_signal("at_end")
#
#
#func play_backwards_and_destroy():
#	$DestroyTimer.start(get_animation_length())
#	$AnimationPlayer.play_backwards("Run")
##	emit_signal("at_start")

#func _on_DestroyTimer_timeout():
#	queue_free()
