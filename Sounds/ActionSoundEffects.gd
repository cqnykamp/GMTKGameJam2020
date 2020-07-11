extends Node2D

onready var jump = preload("res://Effects/JumpSoundEffect.tscn")
onready var crush = preload("res://Effects/CrushSoundEffect.tscn")
onready var goal = preload("res://Effects/GoalSoundEffect.tscn")

func play(sound_name):
	var sound_effect = null
	
	match sound_name:
		"jump":
			sound_effect = jump.instance()
		"goal":
			sound_effect = goal.instance()
		"crush":
			sound_effect = crush.instance()
		"land":
			pass
			
	if sound_effect != null:
		get_tree().current_scene.add_child(sound_effect)
