extends Area2D

var active = false

func set_active(is_active):
	active = is_active
	if active:
		modulate = Color("0000962e")
	else:
		modulate = Color("0000962e")
