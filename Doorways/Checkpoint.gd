tool
extends Area2D

signal player_reached_exit

var active_round = 0

func _ready():
	if not Engine.editor_hint:
		$EditorLabel.visible = false
		active_round = int(name)
#		add_to_group("goals")

func _process(delta):
	if Engine.editor_hint:
		$EditorLabel.text = name

func _on_Next_Round_Start(round_id):
	if round_id == active_round:
		monitorable = true
		monitoring = true

		$Sprite.modulate = Color("ff00c5")
	else:
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		$Sprite.modulate = Color("00ff00c5")
