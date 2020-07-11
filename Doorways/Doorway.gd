tool
extends Area2D

func _ready():
	if not Engine.editor_hint:
		$EditorLabel.visible = false


func _process(delta):
	if Engine.editor_hint:
		$EditorLabel.text = name
		print('hi')
