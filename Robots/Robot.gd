extends StaticBody2D

export var Effect = preload("res://Effects/ExitEffect.tscn")
var effect

var playback = PoolVector2Array()
var sound_effects = PoolStringArray()

var id = 0
var time_factor = 0

var frame_id = 0 setget set_frame_id


var animation_length

var movement_direction = Vector2.ZERO

func _ready():
	add_to_group("robots")
	
	effect = Effect.instance()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	animation_length = effect.get_animation_length()
	
	$Sprite.frame = frame_id
	effect.set_player_image(frame_id)
#	effect.go_to_end()

func set_frame_id(new_frame_id):
	frame_id = new_frame_id
	
	
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
		
		if effect.is_playing():
			effect.stop()
		
		visible = true
		$CollisionShape2D.disabled = false
		effect.visible = false
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
		
		if id - playback.size() < animation_length * 60:
			if not effect.is_playing():
				effect.play(time_factor)
			effect.visible = true
		else:
			
			if effect.is_playing():
				effect.stop()
			effect.visible = false
			
			
func destroy():
	queue_free()
	print('deleted')
	
func _on_Time_Reset():
	pass
	
func _on_Time_Timeout():
	pass
