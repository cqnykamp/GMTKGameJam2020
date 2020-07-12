extends AnimatedSprite


func _on_Timer_timeout():
	LevelNum.play_next_level()
