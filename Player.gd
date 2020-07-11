extends KinematicBody2D

signal done_recording

var MAX_SPEED = 200.0 # maximum horizontal velocity thru air
var JUMP_SPEED = -500.0
var GRAVITY = 1000.0


var velocity = Vector2.ZERO
var jumps_left = 0

var jump = false

var record = PoolVector2Array()


func _physics_process(delta):
	
	var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	velocity.x = input_x * MAX_SPEED
		
	# Adjust facing direction
	if velocity.x > 0:
		$Sprite.set_flip_h(false)
	elif velocity.x < 0:
		$Sprite.set_flip_h(true)
		
	jump = Input.is_action_just_pressed('ui_up')
	
	if is_on_floor():
		jumps_left = 1
	
	if jump and jumps_left > 0:
		velocity.y = JUMP_SPEED
		jumps_left -= 1
			
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	record.append(position)
	
	if $Left.get_overlapping_bodies().size() > 1 and $Right.get_overlapping_bodies().size() > 1:
		#crushed
		emit_signal("done_recording", record)
		queue_free()
		
	elif $Top.get_overlapping_bodies().size() > 1 and $Bottom.get_overlapping_bodies().size() > 1:
		#crushed
		emit_signal("done_recording", record)
		queue_free()
		
	elif position.y > 600:
		emit_signal("done_recording", record)
		queue_free()


		
