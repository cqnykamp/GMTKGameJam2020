extends Node

var level = 1

var NextLevelScreen = preload("res://NextLevelScreen.tscn")

func next_level():
	win()
#	var nextLevelScreen = NextLevelScreen.instance()
#	get_tree().current_scene.add_child(nextLevelScreen)

func play_next_level():
	level += 1
	get_tree().change_scene("res://LevelTwo.tscn")


func win():
	get_tree().change_scene("res://WinScreen.tscn")
