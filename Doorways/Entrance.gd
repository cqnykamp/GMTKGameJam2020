tool
extends Area2D

var active = false

func set_active(is_active):
	active = is_active
	if active:
		$Sprite.modulate = Color("44ff00")
	else:
		$Sprite.modulate = Color("0044ff00")


func _ready():
	if not Engine.editor_hint:
		$EditorLabel.visible = false
		
func _process(delta):
	if Engine.editor_hint:
		$EditorLabel.text = name
