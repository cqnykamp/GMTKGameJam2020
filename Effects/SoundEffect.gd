extends Node2D

func _ready():
	$Play.play()
	
func _process(delta):
	if not $Play.playing:
		queue_free()
