extends Node2D

signal next_round

onready var Player = preload("res://Player/Player.tscn")

var round_id = 0
var passed_round = false

var player

func _ready():
	spawn_player()
	
	for goal in get_tree().get_nodes_in_group("goals"):
		connect("next_round", goal, "_on_Next_Round_Start")
		
	emit_signal("next_round", round_id)
	
	$CountDown.count_down()


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
		if round_id < get_tree().get_nodes_in_group("goals").size() - 1:
		
			round_id += 1
			emit_signal("next_round", round_id)
			passed_round = false
		else:
			print('you won the game')
			return
	
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




