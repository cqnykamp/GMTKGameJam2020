extends StaticBody2D

export var velocity = Vector2(100, 0)

var playback = PoolVector2Array()
var id = 0

func set_playback(record):
	playback = record
	id = 0

func _physics_process(delta):
	if playback.size() > id:
		position = playback[id]
		id += 1
	else:
		queue_free()
		
func destroy():
#	print('destroy')
	queue_free()

