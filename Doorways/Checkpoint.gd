tool
extends Area2D

var GoalSoundEffect = preload("res://Effects/GoalSoundEffect.tscn")

signal player_collected_checkpoint

var active_round

func _ready():
	if not Engine.editor_hint:
		$EditorLabel.visible = false
		active_round = int(name.substr(0, name.length()-2))
		print(active_round)
		add_to_group("checkpoints_all")
		add_to_group("checkpoints" + str(active_round))
		$Sprite.frame = randi() % 3

func _process(delta):
	if Engine.editor_hint:
		$EditorLabel.text = name

func _on_Next_Round_Start(round_id):
	if round_id == active_round:
		set_deferred("monitorable", true)
		set_deferred("monitoring", true)
		visible = true
	else:
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		visible = false


func _on_Checkpoint_body_entered(body):
	#player has gotten it
	emit_signal("player_collected_checkpoint")
	visible = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	var goalSound = GoalSoundEffect.instance()
	get_tree().current_scene.add_child(goalSound)

