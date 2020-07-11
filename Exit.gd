extends Area2D

signal player_reached_exit

var active = false

func set_active(is_active):
	active = is_active
	if active:
		modulate = Color("ae0097")
	else:
		modulate = Color("00ae0097")

func _on_Exit_body_entered(body):
	if active:
		emit_signal("player_reached_exit")
