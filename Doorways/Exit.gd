tool
extends Area2D

signal player_reached_exit

var active_round = 0
var checkpoints_this_round setget set_checkpoint_num
var checkpoints_left

func _ready():
	if not Engine.editor_hint:
		$EditorLabel.visible = false
		active_round = int(name)
		add_to_group("goals")

func _process(delta):
	if Engine.editor_hint:
		$EditorLabel.text = name
		
func set_checkpoint_num(num):
#	print('name: '+str(name)+' num '+str(num))
	checkpoints_this_round = num
	checkpoints_left = checkpoints_this_round
	if checkpoints_this_round == 0:
		no_more_checkpoints()
		
func no_more_checkpoints():
#	print('no more checkpoints')
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
#	$Sprite.modulate = Color("ff00c5")
	visible = true
		
func _on_Next_Round_Start(round_id):
	checkpoints_left = checkpoints_this_round
	if round_id == active_round and checkpoints_left == 0:
		no_more_checkpoints()
	else:
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
	#	$Sprite.modulate = Color("00ff00c5")
		visible = false


#func _on_Next_Round_Start(round_id):
#	if round_id == active_round:
#		monitorable = true
#		monitoring = true
#
#		$Sprite.modulate = Color("ff00c5")
#	else:
#		set_deferred("monitorable", false)
#		set_deferred("monitoring", false)
#		$Sprite.modulate = Color("00ff00c5")
		
func _on_Checkpoint_Collected():
	checkpoints_left -= 1
	if checkpoints_left == 0:
		no_more_checkpoints()
