extends KinematicBody2D

var velocity = Vector2(0,0)


const ROPE_LENGTH = 500.0
const GRAVITY = 800.0
const THURST = 1200.0
const GROUND_ACC = 300
const FRICTION = 300
const AIR_ACC = 100
const JUMP = 300

enum JetpackState {OFF, HOVER, RISE}
enum State {STAND, CROUCH, AIR}
var state = State.STAND
var jetpack_state = JetpackState.OFF
var controller_trigger_pulled_at_least_once = false

var Hook = preload("res://hook.tscn")
onready var hook_line = get_node("/root/main/hook_line")
var hook


func scale(valueIn, baseMin,  baseMax, limitMin, limitMax):
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin
	
func shift_towards(current, target, max_amount):
	if abs(current - target) < max_amount:
		return target
	elif current < target:
		return current + max_amount
	else:
		return current - max_amount

func do_logic_ground(delta):
	if Input.is_action_pressed('right'):
		velocity.x += GROUND_ACC * delta
	elif Input.is_action_pressed("left"):
		velocity.x -= GROUND_ACC * delta
	else:
		velocity.x = shift_towards(velocity.x, 0, FRICTION * delta)
		
	if Input.is_action_pressed("crouch"):
		state = State.CROUCH

	
		
	if Input.is_action_just_pressed('jump'):
		velocity.y = -JUMP
		$hup.play()

	if not is_on_floor():
		state = State.AIR
		
func do_logic_crouch(delta):
	velocity.x = shift_towards(velocity.x, 0, FRICTION * delta)
		
	if not Input.is_action_pressed("crouch"):
		$marine.animation = 'getup'
		state = State.STAND
	
		
	if Input.is_action_just_pressed('jump'):
		velocity.y = -JUMP
		$hup.play()

	if not is_on_floor():
		state = State.AIR

func do_logic_air(delta):
	var grapple_movement_boost = 1
	if hook:
		grapple_movement_boost = 3
	if Input.is_action_pressed('right'):
		velocity.x += AIR_ACC * delta * grapple_movement_boost
	elif Input.is_action_pressed('left'):
		velocity.x -= AIR_ACC * delta * grapple_movement_boost
		
	if is_on_floor():
		$land.play()
		$marine.animation = 'getup'
		state = State.STAND
			
func do_logic_jetpack(delta):
	var axis = -1
	var raw_axis = Input.get_axis("thrust2", "thrust")
	
	if controller_trigger_pulled_at_least_once:
		axis = raw_axis
	elif raw_axis != 0:
		controller_trigger_pulled_at_least_once = true
		axis = raw_axis
		
	if axis > 0.1:
		jetpack_state = JetpackState.RISE
		$particles_2d.emitting = true
	elif axis > -0.9:
		jetpack_state = JetpackState.HOVER
		$particles_2d.emitting = true
	else:
		jetpack_state = JetpackState.OFF
		$particles_2d.emitting = false

func animate():
	if velocity.x < 0:
		$marine.flip_h = true
		$particles_2d.scale.x = -1
		$particles_2d.position.x = 10
	elif velocity.x > 0:
		$marine.flip_h = false
		$particles_2d.scale.x = 1
		$particles_2d.position.x = -10
	$marine.speed_scale = 1
	match state:
		State.STAND:
			if velocity.x > 0.1 or velocity.x < -0.1:
				$marine.animation = 'run'
				$marine.speed_scale = abs(velocity.x)/500
			else:
				if $marine.animation != 'getup':
					$marine.animation = 'default'
		State.CROUCH:
			$marine.animation = 'crouch'
		State.AIR:
			$marine.animation = 'jump'
		

		
func release_grapple():
	if hook:
		hook = null
		hook_line.visible = false


func fire_grapple():
	release_grapple()
	hook_line.visible = true
	var x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	if abs(x) < 0.1 and abs(y) < 0.1:
		y = -1
		if Input.get_action_strength("right") > 0.1:
			x = 1
		elif Input.get_action_strength("left") > 0.1:
			x = -1
		elif $marine.flip_h:
			x = -1
		else:
			x = 1
	var v = Vector2(x, y)

	hook = Hook.instance()
	hook.length = ROPE_LENGTH
	hook.position = position
	hook.position.y -= 30
	get_node("/root/main").add_child(hook)
	var direction = v.normalized()
	hook.apply_central_impulse(direction*1000)
	#else:
	#	hook = null
			
func do_grappled_movement(delta):
		if Input.is_action_pressed("hook_up"):
			hook.length -= delta*50
			
		if Input.is_action_pressed("hook_down"):
			hook.length += delta*50
			
		
		var my_pos = position
		my_pos.y -= 30
		hook_line.points[0]=my_pos
		hook_line.points[1]=hook.position
		
		var rope_length = my_pos.distance_to(hook.position)
		var direction = my_pos.direction_to(hook.position)
		if hook.attached:
			var extension = rope_length - hook.length
			if extension > 0:
				var damping = velocity*0.04
				velocity += direction * extension * 1 - damping
			else:
				hook.length += extension
		
		hook.length = clamp(hook.length, 10, ROPE_LENGTH)
		print(hook.length)

func _physics_process(delta):
	match state:
		State.STAND:
			do_logic_ground(delta)
		State.CROUCH:
			do_logic_crouch(delta)
		State.AIR:
			do_logic_air(delta)
	
	
	do_logic_jetpack(delta)
	
	if Input.is_action_just_released("grapple"):
		release_grapple()
		
	if Input.is_action_just_pressed("grapple"):
		fire_grapple()
		
	if hook:
		do_grappled_movement(delta)

	velocity.y += GRAVITY * delta
	
	if jetpack_state == JetpackState.HOVER:
		if velocity.y < 0:
			jetpack_state = JetpackState.OFF
		else:
			jetpack_state = JetpackState.RISE
		
	if jetpack_state == JetpackState.RISE:
		velocity.y -= THURST * delta

	velocity = move_and_slide(velocity, Vector2.UP)
	
	animate()

	#if is_on_floor():
	#velocity.x = clamp(velocity.x, -200, 200)
	#velocity.y = clamp(velocity.y, -200, 200)
	#else:
	#	velocity.x = clamp(velocity.x, -800, 800)
		#velocity.y = clamp(velocity.y, -800, 800)

#
#	if position.y>700:
#		kill()
#
#	for i in get_slide_count():
#		var collider = get_slide_collision(i).collider
#		if collider.has_method("kill"):
#			if position.y < collider.position.y - 10:
#				velocity.y = -400
#				collider.kill()
		
	
			
	
func kill():
	get_tree().reload_current_scene()


func _on_goal_body_entered(body):
	print("body entered",body)
	if body == self:
		get_tree().change_scene("res://won.tscn")





func _on_marine_frame_changed():
	if $marine.animation == 'run':
		if $marine.frame == 1:
			$footstep.play()
		elif $marine.frame == 5:
			$footstep2.play()


