extends "res://Doorways/Doorway.gd"

signal player_reached_exit

var active_round = 0

func _ready():
	if not Engine.editor_hint:
		active_round = int(name)
		add_to_group("goals")

func _on_Next_Round_Start(round_id):
	if round_id == active_round:
		monitorable = true
		monitoring = true

		$Sprite.modulate = Color("ae0097")
	else:
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		$Sprite.modulate = Color("00ae0097")
