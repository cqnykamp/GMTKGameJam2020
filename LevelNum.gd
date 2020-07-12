extends Node

var level = 1

func next_level():
	level += 1
	get_tree().change_scene("res://LevelTwo.tscn")
