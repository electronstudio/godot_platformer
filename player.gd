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
var jetpack_state = JetpackState.OFF
var controller_trigger_pulled_at_least_once = false

var Hook = preload("res://hook.tscn")
var hook

var air = false

func scale(valueIn, baseMin,  baseMax, limitMin, limitMax):
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin
	
func shift_towards(current, target, max_amount):
	if abs(current - target) < max_amount:
		return target
	elif current < target:
		return current + max_amount
	else:
		return current - max_amount

func do_input_ground(delta):
	if air:
		$land.play()
		$marine.animation = 'land'
		#$marine.play('land')
		air = false
		
		
	if Input.is_action_pressed('right'):
		velocity.x += GROUND_ACC * delta
	elif Input.is_action_pressed("left"):
		velocity.x -= GROUND_ACC * delta
	else:
		velocity.x = shift_towards(velocity.x, 0, FRICTION * delta)
		
	if Input.is_action_pressed("crouch"):
		$marine.animation = 'crouch'
	
		
	if Input.is_action_just_pressed('jump'):
		velocity.y = -JUMP
		$hup.play()
		
	if $marine.animation != 'land':
		if Input.is_action_pressed("crouch"):
			$marine.animation = 'crouch'
		else:
			if velocity.x > 0.1 or velocity.x < -0.1:
				$marine.animation = 'run'
			else:
				$marine.animation = 'default'

func do_input_air(delta):
	air = true
	$marine.animation = 'jump'
	if Input.is_action_pressed('right'):
		velocity.x += AIR_ACC * delta
	elif Input.is_action_pressed('left'):
		velocity.x -= AIR_ACC * delta
			
func do_input_jetpack(delta):
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

func fire_grapple():
	if hook:
		hook = null
		return
	var x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	var v = Vector2(x, y)
	if v.length()<0.1:
		if $marine.flip_h:
			v = Vector2(-1, -1)
		else:
			v = Vector2(1, -1)
	#if v.length()>0.1:
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
			hook.length -= delta*200
			
		if Input.is_action_pressed("hook_down"):
			hook.length += delta*200
			
		
		var my_pos = position
		my_pos.y -= 30
		get_node("/root/main/hook_line").points[0]=my_pos
		get_node("/root/main/hook_line").points[1]=hook.position
		
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
	if is_on_floor():
		do_input_ground(delta)
	else:
		do_input_air(delta)
	
	do_input_jetpack(delta)
	
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
		#velocity.y = shift_towards(velocity.y, 0, THURST * delta)
	if jetpack_state == JetpackState.RISE:
		velocity.y -= THURST * delta

	velocity = move_and_slide(velocity, Vector2.UP)
	

	#if is_on_floor():
	#velocity.x = clamp(velocity.x, -200, 200)
	#velocity.y = clamp(velocity.y, -200, 200)
	#else:
	#	velocity.x = clamp(velocity.x, -800, 800)
		#velocity.y = clamp(velocity.y, -800, 800)
	if velocity.x < 0:
		$marine.flip_h = true
		#scale.x = -1
		$particles_2d.scale.x = -1
		$particles_2d.position.x = 10
	elif velocity.x > 0:
		#scale.x = 1
		$marine.flip_h = false
		$particles_2d.scale.x = 1
		$particles_2d.position.x = -10
		
	if $marine.animation == 'run':
		var s = abs(velocity.x)/500
		$marine.speed_scale = s
	else:
		$marine.speed_scale = 1
	
	if position.y>700:
		kill()

	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider.has_method("kill"):
			if position.y < collider.position.y - 10:
				velocity.y = -400
				collider.kill()
		
	
			
	
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


func _on_marine_animation_finished():
	if $marine.animation == 'land':
		$marine.animation = 'default'
		pass
