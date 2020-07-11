extends StaticBody2D

var playback = PoolVector2Array()
var sound_effects = PoolStringArray()
var id = 0
var time_factor = 0

var movement_direction = Vector2.ZERO

func _ready():
	add_to_group("robots")

func set_playback(record, sfx):
	playback = record
	sound_effects = sfx
	id = 0
	
func start_at_end(record, sfx):
	playback = record
	sound_effects = sfx
	id = playback.size() - 1
	
func _on_New_Time(time, _timeFactor):
	id = int(time * 60)
	time_factor = _timeFactor

func _physics_process(delta):
	id = max(id, 0)
	
	if id < playback.size():
		visible = true
		$CollisionShape2D.disabled = false
		position = playback[id]
		if id > 0:
			movement_direction = playback[id] - playback[id-1]
			movement_direction = movement_direction.normalized()
		else:
			movement_direction = playback[id] - Vector2.ZERO
			movement_direction = movement_direction.normalized()
			
		
		if time_factor != 0:
			$ActionSoundEffects.play(sound_effects[id])
	else:
		$CollisionShape2D.disabled = true
		visible = false

func destroy():
	queue_free()
	print('deleted')
	
func _on_Time_Reset():
	pass
	
func _on_Time_Timeout():
	pass
