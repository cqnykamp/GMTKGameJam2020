extends KinematicBody2D

signal player_death

# General Movement
# vx_max was 450
const vx_max = 450.0 # maximum horizontal velocity thru air
# y_h was 200
const y_h = 200.0 # max peak height during jump
# x_h was 150
const x_h = 150.0 # horz distance (to peak) at max horz vel
const short_jump_gravity_mod = 5.0
const fall_arc_gravity_mod = 1.5

const jump_chain = 1
const dash_chain = 0
const dash_dist = 100
const dash_speed = 1500
const dash_frames = 4
const jump_threshold = 75 # milliseconds

# Interacting with enemies
const floor_bounce_jump_mod = 1 #0.7

const jump_chain_reset = false
const jump_chain_add_mod = -1
const dash_chain_reset = false
const dash_chain_add_mod = 0

var jump_speed = 2 * y_h * vx_max / x_h
var gravity = -2*y_h * (vx_max *vx_max) / (x_h*x_h)
var jumps_left = 0
var dashs_left = 0
var jump_timestamp = 0

var dash_start_x
var dash_goal_x
var last_move_vel_x

var vel_before_collision

var extents

# General
var velocity = Vector2()
var collisions_h = Array()
var collisions_v = Array()
var dt

enum StateH {WALKING, DASHING, SLIDING, DEAD}
var state_h

enum StateV {FALLING, HANGING}
var state_v

# Horizontal
# Sliding and Dead
var sliding_ref
var sliding_surface

# Vertical
var gravity_mod
var last_vertical_action = "none"

var dash_frame


func _ready():
	print("jump speed: " + str(jump_speed)+" gravity: " + str(gravity))
	set_meta("type", "player")
	
	var shape = shape_owner_get_shape(0, 0)
	extents = shape.extents
	
	walking_start()
	falling_start()


func _physics_process(delta):
	dt = delta
	collision_detection()
	
	if position.y > 1000:
		dead_start()
		hanging_start()

	match state_h:
		StateH.WALKING:
			walking_horizontal()
		StateH.SLIDING:
			sliding_horizontal()
		StateH.DASHING:
			dashing_horizontal()
		StateH.DEAD:
			dead_horizontal()
			
	match state_v:
		StateV.FALLING:
			falling_vertical()
		StateV.HANGING:
			hanging_vertical()
	
	vel_before_collision = velocity

	velocity.y = -1*velocity.y
	velocity = move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
	velocity.y = -1*velocity.y
	
#	print(get_slide_count())
#	print(randi())
	
#	print("vel after slide: "+str(velocity.x))


func collision_detection():
	
	collisions_h.clear()
	collisions_v.clear()
	
	var refs_v = []
	
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var col = collision.collider
		var col_type = col.get_meta("type") if col.has_meta("type") else "none"
	
		var surface = "none"
		match collision.normal:
			Vector2(0,-1):
				surface = "floor"
			Vector2(0,1):
				surface = "ceiling"
			Vector2(1,0):
				surface = "left"
			Vector2(-1,0):
				surface = "right"
			_:
				print("Found invalid surface")
		
		var collision_data = {
			"collision": collision,
			"col": col,
			"type": col_type,
			"surface": surface
		}
		
		if surface=="floor" or surface=="ceiling":
			collisions_v.append(collision_data)
			refs_v.append(col)
		elif surface=="left" or surface=="right":
			collisions_h.append(collision_data)
	
	for cdata in collisions_h:
		if refs_v.find(cdata.col) != -1:
			collisions_h.erase(cdata)
			print('found duplicate ref collision')
			

func filter_by(collision_data, typeEntry, values:Array):
	var filtered_collision_data = []
	for cdata in collision_data:
		if values.has(cdata[typeEntry]):
			filtered_collision_data.append(cdata)
	return filtered_collision_data

	

func collided_with_enemy_wall():
	for cdata in collisions_h:
		if cdata.type == "enemy":
			return true
	return false

func enemy_wall_collisions():
	var datas = []
	for cdata in collisions_h:
		if cdata.type == "enemy":
			datas.append(cdata)
	return datas
	
func get_facing_direction():
	return -1 if $Sprite.flip_h else 1
	
	
func walking_start():
	print('State: walking')
	state_h = StateH.WALKING

func walking_horizontal():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var dash = Input.is_action_just_pressed('ui_dash')
	
	if collided_with_enemy_wall():
		sliding_start_player_initiated()
	elif dash and dashs_left > 0:
		dashs_left -= 1
		dashing_start()
		hanging_start()
	else:
		velocity.x = 0
		if right:
			velocity.x += vx_max
		if left:
			velocity.x -= vx_max
			
		# Adjust facing direction
		if velocity.x > 0:
			$Sprite.set_flip_h(false)
		elif velocity.x < 0:
			$Sprite.set_flip_h(true)
			
func dashing_start():
	print('State (horizontal): dashing')
	state_h = StateH.DASHING
	
	var direction = get_facing_direction()
	
	last_move_vel_x = velocity.x
#	state = State.DASH
#	print('flip_h: '+str($Sprite.flip_h)+' direction: '+str(direction))
	velocity.x = direction * dash_speed
	dash_start_x = get_position().x
	dash_goal_x = dash_start_x + direction * dash_dist
	print('dash_start: '+str(dash_start_x)+' dash_goal: '+str(dash_goal_x))
	dash_frame = dash_frames


func dashing_horizontal():
	dash_frame -= 1
	
	if collided_with_enemy_wall():
#		$DashHang.stop()
		sliding_start_player_initiated()
	elif dash_frame == 0:
		# stop dashing horizontally, but still hang
		velocity.x = last_move_vel_x
#		print(position.x)
		$DashHang.start()
		
	print('vel at dash: '+str(velocity.x))
	
func snap_to_sliding_enemy():
	var direction = 1 if sliding_surface=="left" else -1
	var distance = sliding_ref.extents.x + extents.x
	position.x = sliding_ref.position.x + direction * distance

	
func sliding_start_general():
	print('State: sliding')
	state_h = StateH.SLIDING
	snap_to_sliding_enemy()

	
func sliding_start_player_initiated():
	print('Sliding player initiated')
	sliding_ref = null
	sliding_surface = null
	
	for cdata in collisions_h:
		if cdata.type == "enemy":
			sliding_ref = cdata.col
			sliding_surface = cdata.surface
			break
				
	if sliding_ref == null:
		print("Sliding start no ref")
		
	sliding_start_general()

	
func sliding_horizontal():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
#	var dash = Input.is_action_just_pressed('ui_dash')

#	print(enemy_wall_collisions().size())
	var opposite_sliding_surface = "right" if sliding_surface=="left" else "left"
#	print(collisions_h)
	if filter_by(collisions_h, "surface", [opposite_sliding_surface]).size() > 0:
		#We're not actually colliding with the sliding wall
		dead_start()
		hanging_start()
		pass
	else:
		velocity.x = 0
		var distance_y = extents.y + sliding_ref.extents.y
		if abs(position.y - sliding_ref.position.y) > distance_y:
			walking_start() 
		if left and sliding_surface=="right":
			velocity.x = -vx_max
			walking_start()
		elif right and sliding_surface=="left":
			velocity.x = vx_max
			walking_start()
		else:
			snap_to_sliding_enemy()

func dead_start():
	# HORIZONTAL
	print('State: dead')
	state_h = StateH.DEAD
	
	emit_signal("player_death")
	position = Vector2(500, 100)
	velocity = Vector2(0,0)
	dashs_left = 0
	jumps_left = 0
	$RespawnTimer.start()


func dead_horizontal():
	pass
	
func _on_enemy_initiate_contact(enemy_ref, surface):
	if vel_before_collision.x==0 and state_h != StateH.SLIDING and state_h != StateH.DEAD:
#		print('vel at enemy initiated contact: '+str(velocity.x))
#		print(vel_before_collision)
#		print(sliding_ref)
#		print(enemy_ref)
		sliding_ref = enemy_ref
		sliding_surface = surface
		print('enemy initiated contact, surface: '+str(sliding_surface))
		sliding_start_general()	
	pass







func standing_on(type):
	for cdata in collisions_v:
		if cdata.type==type and cdata.surface=="floor":
			return true
	return false
	
func enemies_on_floor():
	var datas = []
	for cdata in collisions_v:
		if cdata.type == "enemy" and cdata.surface=="floor":
			datas.append(cdata)
	return datas
	
	

func falling_start():
	print('State (vertical): falling')
	state_v = StateV.FALLING
	
func falling_vertical():
	var jump = Input.is_action_just_pressed('ui_up')
	var jumpHold = Input.is_action_pressed('ui_up')
	
	if jump:
		jump_timestamp = OS.get_ticks_msec()
	
	# Gravity
	if velocity.y <= 0:
		gravity_mod = fall_arc_gravity_mod
	elif not jumpHold and last_vertical_action=="jump":
		gravity_mod = short_jump_gravity_mod
	else:
		gravity_mod = 1
	velocity.y += gravity * gravity_mod * dt
	var enemy_collisions = filter_by(collisions_v, "type", ["enemy"])
#	print(enemy_collisions)

	if standing_on("platform"):
		dashs_left = dash_chain
		jumps_left = jump_chain

	elif standing_on("enemy"):
#		print(enemies_on_floor())
		for enemy_data in enemies_on_floor():
				
			enemy_data.col.hit()
			# Reset action chains as configured above
			dashs_left = dash_chain+dash_chain_add_mod if dash_chain_reset else dashs_left
			jumps_left = jump_chain+jump_chain_add_mod if jump_chain_reset else jumps_left
			
			velocity.y = jump_speed * floor_bounce_jump_mod
			last_vertical_action = "bounce"
			
#		if OS.get_ticks_msec() - jump_timestamp < jump_threshold:
#			velocity.y = jump_speed

	for enemy_data in filter_by(enemy_collisions, "surface", ["ceiling"]):
		enemy_data.col.hit()
		
	
	if jumps_left > 0 and OS.get_ticks_msec() - jump_timestamp < jump_threshold:
		last_vertical_action = "jump"
		velocity.y = jump_speed
		jumps_left -= 1
		
func hanging_start():
	print('State (vertical): hanging')
	state_v = StateV.HANGING
	velocity.y = 0
	
func hanging_vertical():
	pass




func start_hang():
#	state = State.HANG
	$DashHang.start()
	velocity.x = last_move_vel_x
	velocity.y = 0
	


func _on_DashHang_timeout():
	$DashHang.stop()
	if state_h == StateH.DASHING:
		walking_start()
		falling_start()
	#	print('end hang pos: '+str(get_position().x))
	
		
func _on_Knockoff_timeout():
	$Knockoff.stop()
#	state = State.HANG
#	ceiling_bounce_hang = false
	$CeilingHang.start()
	velocity.y = 0


func _on_CeilingHang_timeout():
	$CeilingHang.stop()
#	state = State.MOVE


func _on_RespawnTimer_timeout():
	$RespawnTimer.stop()
	walking_start()
	falling_start()
