extends Node2D

func _ready():
	$Play.play()
	$AnimatedSprite.play()
	$StartFadeOut.start()
#	$AnimationPlayer.play("FadeIn")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		queue_free()


func _on_StartFadeOut_timeout():
	$AnimationPlayer.play("FadeOut")
