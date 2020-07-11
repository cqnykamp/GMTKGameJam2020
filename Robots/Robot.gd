extends StaticBody2D

export var velocity = Vector2(100, 0)

var playback = PoolVector2Array()
var sound_effects = PoolStringArray()
var id = 0
var time_factor = 0

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
		if time_factor != 0:
			$ActionSoundEffects.play(sound_effects[id])
	else:
		$CollisionShape2D.disabled = true
		visible = false

func destroy():
	queue_free()
	
func _on_Time_Reset():
	pass
	
func _on_Time_Timeout():
	pass
