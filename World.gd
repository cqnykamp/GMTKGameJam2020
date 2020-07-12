extends Node2D

signal next_round

onready var Player = preload("res://Player/Player.tscn")
onready var RewindEffect = preload("res://Effects/RewindEffect.tscn")
onready var countDown = $CanvasLayer/CountDown

var SpawnEffect = preload("res://Effects/SpawnEffect.tscn")

var round_id = 0
var passed_round = false

var player
var spawner

var active_playing = true

func _ready():
	
	for goal in get_tree().get_nodes_in_group("goals"):
		connect("next_round", goal, "_on_Next_Round_Start")
		var checkpoints = get_tree().get_nodes_in_group("checkpoints" + str(goal.name))
		for checkpoint in checkpoints:
			connect("next_round", checkpoint, "_on_Next_Round_Start")
			checkpoint.connect("player_collected_checkpoint", goal, "_on_Checkpoint_Collected")
	
		goal.checkpoints_this_round = checkpoints.size()
	
	emit_signal("next_round", round_id)
	$PauseAfterRewind.start()


func _on_CountDown_new_time(time, time_factor):
	get_tree().call_group("robots", "_on_New_Time", time, time_factor)


func _on_CountDown_timeout():
	if active_playing:
		print('time is out, round failed')
		player.die()
	else:
		print('time is out, but we were not playing anyway')
	
func _on_Player_player_died():
	active_playing = false
	get_tree().call_group("robots", "_on_Time_Timeout")
	countDown.count_back_up(0)
	$PauseAfterTimeout.start()


func _on_Player_player_reached_exit():
	active_playing = false
	get_tree().call_group("robots", "_on_Time_Timeout")
	passed_round = true
#	countDown.count_back_up(0)
	$PauseAfterTimeout.start()

func _on_PauseAfterTimeout_timeout():
	if passed_round and not round_id < get_tree().get_nodes_in_group("goals").size() - 1:
		if LevelNum.level == 1:
			LevelNum.next_level()
		else:
			LevelNum.win()
			
	else:
		countDown.count_back_up(-5)
		
		var rewindEffect = RewindEffect.instance()
		$CanvasLayer.add_child(rewindEffect)
		rewindEffect.global_position = get_viewport_rect().size / 2



func _on_CountDown_time_reset():
	if passed_round:
		if round_id < get_tree().get_nodes_in_group("goals").size() - 1:
		
			round_id += 1

			passed_round = false
			
			var effect_spawner = get_node("Entrances/" + str(round_id))
			var spawnEffect = SpawnEffect.instance()
			spawnEffect.position = effect_spawner.global_position
			get_tree().current_scene.add_child(spawnEffect)
			spawnEffect.play(1)


	
	print('time back to full, now we play again')
	get_tree().call_group("robots", "_on_Time_Reset")
	countDown.count_back_up(0)
	$PauseAfterRewind.start()

func _on_PauseAfterRewind_timeout():
	emit_signal("next_round", round_id)
	
	active_playing = true
	countDown.count_down()
	spawn_player()


func spawn_player():

	spawner = get_node("Entrances/" + str(round_id))
	player = Player.instance()
	player.connect("player_died", self, "_on_Player_player_died")
	player.connect("player_reached_exit", self, "_on_Player_player_reached_exit")
	player.position = spawner.global_position
	get_tree().current_scene.add_child(player)

	var cameraTracker = RemoteTransform2D.new()
	cameraTracker.remote_path = NodePath("/root/World/Camera2D")
	player.add_child(cameraTracker)
	cameraTracker.position = Vector2(0,0)


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()
