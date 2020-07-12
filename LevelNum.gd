extends Node

var level = 1

var FirstLevel = preload("res://SMDesign3.tscn")
var NextLevelScreen = preload("res://NextLevelScreen.tscn")
var SecondLevel = preload("res://LevelTwo.tscn")

func reload_level():
	if level == 1:
		get_tree().change_scene_to(FirstLevel)
	else:
		get_tree().change_scene_to(SecondLevel)

func next_level():
	win()
#	var nextLevelScreen = NextLevelScreen.instance()
#	get_tree().current_scene.add_child(nextLevelScreen)

func play_next_level():
	level += 1
	get_tree().change_scene("res://LevelTwo.tscn")


func win():
	get_tree().change_scene("res://WinScreen.tscn")
