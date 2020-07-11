extends KinematicBody2D

signal player_death

# General Movement
# MAX_SPEED was 450
const MAX_SPEED = 450.0 # maximum horizontal velocity thru air
# y_h was 200
const y_h = 200.0 # max peak height during jump
# x_h was 150
const x_h = 150.0 # horz distance (to peak) at max horz vel
const short_jump_gravity_mod = 5.0
const fall_arc_gravity_mod = 1.5

var jump_speed = 2 * y_h * MAX_SPEED / x_h
var gravity = -2*y_h * (MAX_SPEED *MAX_SPEED) / (x_h*x_h)
var jumps_left = 0

var jump_timestamp
const jump_threshold = 75 #milliseconds 

# General
var velocity = Vector2.ZERO

# Vertical
var gravity_mod

var jump_button


func _physics_process(delta):
	
	var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	velocity.x = input_x * MAX_SPEED
		
	# Adjust facing direction
	if velocity.x > 0:
		$Sprite.set_flip_h(false)
	elif velocity.x < 0:
		$Sprite.set_flip_h(true)
		
	var jump = Input.is_action_just_pressed('ui_up')
	jump_button = jump
	var jumpHold = Input.is_action_pressed('ui_up')
	
	if jump:
		jump_timestamp = OS.get_ticks_msec()
	
	# Gravity
	if velocity.y <= 0:
		gravity_mod = fall_arc_gravity_mod
	elif not jumpHold:
		gravity_mod = short_jump_gravity_mod
	else:
		gravity_mod = 1
		
	velocity.y += gravity * gravity_mod * delta

	if is_on_floor():
		jumps_left = 1
	
	if jumps_left > 0 and OS.get_ticks_msec() - jump_timestamp < jump_threshold:
		velocity.y = jump_speed
		jumps_left -= 1
		
		
	velocity.y = -1 * velocity.y
	velocity = move_and_slide(velocity)
	velocity.y = -1 * velocity.y
	
func get_facing_direction():
	return -1 if $Sprite.flip_h else 1
