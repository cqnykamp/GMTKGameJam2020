extends Node2D

signal at_end
signal at_start

func play_forward():
	$AnimationPlayer.play("Run")
#	emit_signal("at_end")
	queue_free()
	
#func play_backwards():
#	$AnimationPlayer.play_backwards("Run")
#	emit_signal("at_start")
#	queue_free()
