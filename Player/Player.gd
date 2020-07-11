extends KinematicBody2D

signal player_died
signal player_reached_exit

var PlayerReplay = preload("res://Player/PlayerReplay.tscn")
var Robot = preload("res://Robots/Robot.tscn")

var MAX_SPEED = 200.0 # maximum horizontal velocity thru air
var JUMP_SPEED = -500.0
var GRAVITY = 1000.0


var velocity = Vector2.ZERO
var jumps_left = 0
var on_ground = false

var jump = false

var record = PoolVector2Array()
var sound_effects = PoolStringArray()


func _physics_process(delta):
	
	var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	var this_sound_effect = "none"

	velocity.x = input_x * MAX_SPEED
		
	# Adjust facing direction
	if velocity.x > 0:
		$Sprite.set_flip_h(false)
	elif velocity.x < 0:
		$Sprite.set_flip_h(true)
		
	jump = Input.is_action_just_pressed('ui_up')
	
	if is_on_floor():
		on_ground = true
		jumps_left = 1
	else:
		on_ground = false

	
	if jump and on_ground and jumps_left > 0:
		velocity.y = JUMP_SPEED
		jumps_left -= 1
		
		this_sound_effect = "jump"
		$ActionSoundEffects.play(this_sound_effect)
			
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	record.append(position)
	sound_effects.append(this_sound_effect)
	
	if $Left.get_overlapping_bodies().size() > 0 and $Right.get_overlapping_bodies().size() > 0:
		#crushed
		sound_effects.remove(sound_effects.size()-1)
		sound_effects.append("crush")
		$ActionSoundEffects.play("crush")
		die()
		
	elif $Top.get_overlapping_bodies().size() > 0 and $Bottom.get_overlapping_bodies().size() > 0:
		#crushed
		print('crushed vertical')
		sound_effects.remove(sound_effects.size()-1)
		sound_effects.append("crush")
		$ActionSoundEffects.play("crush")
		die()
		
	elif position.y > 600:
		die()
		
func die():
	emit_signal("player_died")
	$CollisionBox.disabled = true
	
	spawn_clone()
	queue_free()

func _on_GoalDetector_area_entered(area):
	# player has reached their exit
	emit_signal("player_reached_exit")
	$CollisionBox.set_deferred("disabled", true)
	
	sound_effects.remove(sound_effects.size()-1)
	sound_effects.append("goal")
	$ActionSoundEffects.play("goal")
	
	spawn_robot()
	queue_free()

func spawn_clone():
	var playerReplay = PlayerReplay.instance()
	playerReplay.start_at_end(record, sound_effects)
	get_tree().current_scene.call_deferred("add_child",playerReplay)
	playerReplay.global_position = global_position
	
func spawn_robot():
	var robot = Robot.instance()
	robot.start_at_end(record, sound_effects)
	get_tree().current_scene.call_deferred("add_child",robot)
	robot.global_position = global_position
