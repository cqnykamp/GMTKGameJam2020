extends Node2D

signal next_round

onready var Player = preload("res://Player/Player.tscn")

var round_id = 0
var passed_round = false

onready var player = $Player

func _ready():
	for goal in get_tree().get_nodes_in_group("goals"):
		connect("next_round", goal, "_on_Next_Round_Start")
		
	emit_signal("next_round", round_id)
	
	$CountDown.count_down()


#signal destroy_robots

#
#onready var player = $Player
#
#func _ready():
##	$Entrances.visible = false
#	$Player.position = get_node("Entrances/" + str(entrance_id)).global_position
#	update_portals()
#	$Timer.start()
#
#func _process(delta):
#	$Label.text = str(ceil($Timer.time_left))
#
#func play_another_round():
#
#	if entrance_id == $Entrances.get_child_count():
#		return
#
#	emit_signal("destroy_robots")
#	update_portals()
#
#	player = Player.instance()
#	player.connect("player_died", self, "_on_Player_died")
#	player.position = get_node("Entrances/" + str(entrance_id)).global_position
#	get_tree().current_scene.add_child(player)
#
#	for player_record in player_recordings:
#		var robot = Robot.instance()
#		connect("destroy_robots", robot, "destroy")
#		robot.set_playback(player_record)
#		get_tree().current_scene.add_child(robot)
#
#	$Timer.start()
#
#
#func player_reached_exit():
#	entrance_id += 1
#	var record = player.record
#	player_recordings.append(record)
#	player.queue_free()
#	play_another_round()
#
#func update_portals():
#	for exit in $Exits.get_children():
#		if exit.name == str(entrance_id):
#			exit.set_active(true)
#			exit.connect("player_reached_exit", self, "player_reached_exit")
#		else:
#			exit.set_active(false)
#
#	for entrance in $Entrances.get_children():
#		if entrance.name == str(entrance_id):
#			entrance.set_active(true)
#		else:
#			entrance.set_active(false)
#
#
#func _on_Timer_timeout():
#	player.die()
#
#


func _on_CountDown_new_time(time, time_factor):
	get_tree().call_group("robots", "_on_New_Time", time, time_factor)


func _on_CountDown_timeout():
	print('time is out, round failed')
	player.die()
	
func _on_Player_player_died():
	get_tree().call_group("robots", "_on_Time_Timeout")
	$PauseAfterTimeout.start()

func _on_Player_player_reached_exit():
	get_tree().call_group("robots", "_on_Time_Timeout")
	passed_round = true
	$CountDown.count_back_up(0)
	$PauseAfterTimeout.start()

func _on_PauseAfterTimeout_timeout():
	$CountDown.count_back_up(-3)



func _on_CountDown_time_reset():
	if passed_round:
		round_id += 1
		emit_signal("next_round", round_id)
		passed_round = false
	
	print('time back to full, now we play again')
	get_tree().call_group("robots", "_on_Time_Reset")
	$CountDown.count_back_up(0)
	$PauseAfterRewind.start()

func _on_PauseAfterRewind_timeout():
	$CountDown.count_down()
	spawn_player()




func spawn_player():
	var spawner = get_node("Entrances/" + str(round_id))
	player = Player.instance()
	player.connect("player_died", self, "_on_Player_player_died")
	player.connect("player_reached_exit", self, "_on_Player_player_reached_exit")
	player.position = spawner.global_position
	get_tree().current_scene.add_child(player)




