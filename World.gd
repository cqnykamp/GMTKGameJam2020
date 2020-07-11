extends Node2D

signal destroy_robots

onready var Robot = preload("res://Robot.tscn")
onready var Player = preload("res://Player.tscn")

var player_recordings = Array()
var entrance_id = 0

onready var player = $Player

func _ready():
#	$Entrances.visible = false
	$Player.position = get_node("Entrances/" + str(entrance_id)).global_position
	update_portals()
	$Timer.start()
	
func _process(delta):
	$Label.text = str(ceil($Timer.time_left))

func _on_Player_done_recording():

	if entrance_id == $Entrances.get_child_count():
		return
	
	emit_signal("destroy_robots")

	update_portals()

	player = Player.instance()
	player.position = get_node("Entrances/" + str(entrance_id)).global_position
	player.connect("done_recording", self, "_on_Player_done_recording")
	get_tree().current_scene.add_child(player)
	
	for player_record in player_recordings:
		var robot = Robot.instance()
		connect("destroy_robots", robot, "destroy")
		robot.set_playback(player_record)
		get_tree().current_scene.add_child(robot)
	
	$Timer.start()
		
		
func player_reached_exit():
	entrance_id += 1
	var record = player.record
	player_recordings.append(record)
	player.queue_free()
	_on_Player_done_recording()


func update_portals():
	for exit in $Exits.get_children():
		if exit.name == str(entrance_id):
			exit.set_active(true)
			exit.connect("player_reached_exit", self, "player_reached_exit")
		else:
			exit.set_active(false)
			
	for entrance in $Entrances.get_children():
		if entrance.name == str(entrance_id):
			entrance.set_active(true)
		else:
			entrance.set_active(false)


func _on_Timer_timeout():
	player.queue_free()
	_on_Player_done_recording()
