extends "res://Doorways/Doorway.gd"

var active = false

func set_active(is_active):
	active = is_active
	if active:
		$Sprite.modulate = Color("0000962e")
	else:
		$Sprite.modulate = Color("0000962e")
