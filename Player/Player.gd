extends KinematicBody2D

signal player_died
signal player_reached_exit

var PlayerReplay = preload("res://Player/PlayerReplay.tscn")
var PlayerReplayExplosion = preload("res://Player/PlayerReplayExplosion.tscn")
var Robot = preload("res://Robots/Robot.tscn")
var ExitEffect = preload("res://Effects/ExitEffect.tscn")

var MAX_SPEED = 200.0 # maximum horizontal velocity thru air
var JUMP_SPEED = -500.0
var GRAVITY = 1000.0

var velocity = Vector2.ZERO
var jumps_left = 0
var on_ground = false

var short_jump_gravity_mod = 2.0
var fall_gravity_mod = 1.5

var jump = false
var jump_held = false
var gravity_modifier = 1.0

var record = PoolVector2Array()
var sound_effects = PoolStringArray()

var unsorted = Array()
var unsorted_trigger = Array()
var left = Array()
var right = Array()
var top = Array()
var bottom = Array()


func _ready():
	if LevelNum.level == 1:
		$Sprite.frame = 0
	else:
		$Sprite.frame = 2


func _process(delta):
	pass
	

func _physics_process(delta):
	
	unsorted.clear()
	unsorted_trigger.clear()
	left.clear()
	right.clear()
	top.clear()
	bottom.clear()
	
	for body in $Left.get_overlapping_bodies():
		if body is TileMap:
			left.append(body)
		else:
			unsorted.append(body)
			unsorted_trigger.append("left")
	for body in $Right.get_overlapping_bodies():
		if body is TileMap:
			right.append(body)
		else:
			unsorted.append(body)
			unsorted_trigger.append("right")
	for body in $Top.get_overlapping_bodies():
		if body is TileMap:
			top.append(body)
		else:
			unsorted.append(body)
			unsorted_trigger.append("top")
	for body in $Bottom.get_overlapping_bodies():
		if body is TileMap:
			bottom.append(body)
		else:
			unsorted.append(body)
			unsorted_trigger.append("bottom")
	
	var should_skip = Array()
	for body in unsorted:
		if should_skip.has(body):
			break
		
		if unsorted.count(body) == 1:
			match unsorted_trigger[unsorted.find(body)]:
				"left":
					left.append(body)
				"right":
					right.append(body)
				"top":
					top.append(body)
				"bottom":
					bottom.append(body)
			
		elif unsorted.count(body) > 1:
			var collision_direction = Vector2.ZERO
			if abs(body.movement_direction.x) > abs(body.movement_direction.y):
				collision_direction = Vector2(body.movement_direction.x, 0).normalized()
			else:
				collision_direction = Vector2(0, body.movement_direction.y).normalized()

			match collision_direction:
				Vector2.UP:
					bottom.append(body)
				Vector2.DOWN:
					top.append(body)
				Vector2.LEFT:
					right.append(body)
				Vector2.RIGHT:
					left.append(body)
					
			should_skip.append(body)
	
#	if $Left.get_overlapping_bodies().size() > 0 and $Right.get_overlapping_bodies().size() > 0:
#		var horizontal_collisions = Array()
#		for body in $Left.get_overlapping_bodies():
#			if not horizontal_collisions.has(body.name):
#				horizontal_collisions.append(body.name)
#		for body in $Right.get_overlapping_bodies():
#			if not horizontal_collisions.has(body.name):
#				horizontal_collisions.append(body.name)
#
#		if horizontal_collisions.size() > 1:
#			print('crushed horizontal')
#			print(horizontal_collisions)
#			sound_effects.remove(sound_effects.size()-1)
#			sound_effects.append("crush")
#			$ActionSoundEffects.play("crush")
#			die()
#
#	elif $Top.get_overlapping_bodies().size() > 0 and $Bottom.get_overlapping_bodies().size() > 0:
#		var vertical_collisions = Array()
#		for body in $Left.get_overlapping_bodies():
#			if not vertical_collisions.has(body.name):
#				vertical_collisions.append(body.name)
#		for body in $Right.get_overlapping_bodies():
#			if not vertical_collisions.has(body.name):
#				vertical_collisions.append(body.name)
#
#		if vertical_collisions.size() > 1:
#			print('crushed vertical')
#			print(vertical_collisions)
#			sound_effects.remove(sound_effects.size()-1)
#			sound_effects.append("crush")
#			$ActionSoundEffects.play("crush")
#			die()
#
#	elif position.y > 600:
#		die()
	
	var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	var this_sound_effect = "none"

	velocity.x = input_x * MAX_SPEED
		
	# Adjust facing direction
	if velocity.x > 0:
		$Sprite.set_flip_h(false)
	elif velocity.x < 0:
		$Sprite.set_flip_h(true)
		
	jump = Input.is_action_just_pressed('ui_up')
	jump_held = Input.is_action_pressed('ui_up')
	
	if is_on_floor():
		on_ground = true
		jumps_left = 1
	else:
		on_ground = false

	if velocity.y > 0:
		gravity_modifier = fall_gravity_mod
	elif velocity.y < 0 and not jump_held:
		# aka if still traveling up and jump released
		gravity_modifier = short_jump_gravity_mod
	else:
		gravity_modifier = 1.0

	if jump and on_ground and jumps_left > 0:
		velocity.y = JUMP_SPEED
		jumps_left -= 1
		
		this_sound_effect = "jump"
		$ActionSoundEffects.play(this_sound_effect)
	
	velocity.y += GRAVITY * gravity_modifier * delta
	
	if bottom.size() > 0 and top.size() > 0:
		print('crushed vertical')
		sound_effects.remove(sound_effects.size()-1)
		sound_effects.append("crush")
		$ActionSoundEffects.play("crush")
		explode()

	elif left.size() > 0 and right.size() > 0:
		print('crushed horizontal')
		sound_effects.remove(sound_effects.size()-1)
		sound_effects.append("crush")
		$ActionSoundEffects.play("crush")
		explode()
		
	if position.y > 600:
		explode()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
#	$BottomRay.force_raycast_update()
#	$TopRay.force_raycast_update()
	
#	bottom = $BottomRay.is_colliding()
#	top = $TopRay.is_colliding()

	
	record.append(position)
	sound_effects.append(this_sound_effect)
	

func explode():
	emit_signal("player_died")
	$CollisionBox.disabled = true

	spawn_explosion_clone()
	queue_free()
	
		
func die():
	# this one is time out, not explode
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
	
#	print('spawn robot')
	spawn_robot()
	queue_free()
	
#	var exitEffect = ExitEffect.instance()
#	exitEffect.set_player_image($Sprite.frame)
#	exitEffect.global_position = global_position
#	get_tree().current_scene.add_child(exitEffect)
#	exitEffect.play_forward_and_destroy()
#	exitEffect.connect("at_end", self, "_on_Exit_Animation_Complete")
#	visible = false
	
func _on_Exit_Animation_Complete():
	pass

func spawn_clone():
	var playerReplay = PlayerReplay.instance()
	playerReplay.frame_id = $Sprite.frame
	get_tree().current_scene.call_deferred("add_child",playerReplay)
	playerReplay.call_deferred("start_at_end", record, sound_effects)
	playerReplay.global_position = global_position
	
func spawn_explosion_clone():
	# the one difference is explosion
	var playerReplay = PlayerReplayExplosion.instance()
	playerReplay.frame_id = $Sprite.frame
	get_tree().current_scene.call_deferred("add_child",playerReplay)
	playerReplay.call_deferred("start_at_end", record, sound_effects)
	playerReplay.global_position = global_position
	
func spawn_robot():
	var robot = Robot.instance()
	robot.frame_id = $Sprite.frame
	get_tree().current_scene.call_deferred("add_child",robot)
	robot.call_deferred("start_at_end", record, sound_effects)
	robot.global_position = global_position


func _on_CheckpointDetector_area_entered(area):
	pass
