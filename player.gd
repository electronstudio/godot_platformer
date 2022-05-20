extends KinematicBody2D

var velocity = Vector2(0,0)
var jump_timer = 0

const ROPE_LENGTH = 500.0
const GRAVITY = 800.0
const THURST = 1200.0
const GROUND_ACC = 300
const FRICTION = 300
const AIR_ACC = 100
const JUMP = 500

enum JetpackState {OFF, HOVER, RISE}
var jetpack_state = JetpackState.OFF
var controller_trigger_pulled_at_least_once = false

var Hook = preload("res://hook.tscn")
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

func _physics_process(delta):
	if is_on_floor():
		$alien_pink.animation = 'idle_front'
		jump_timer = 0.5
		if Input.is_action_pressed('right'):
			velocity.x += GROUND_ACC * delta
			$alien_pink.animation = 'walk'
		elif Input.is_action_pressed("left"):
			velocity.x -= GROUND_ACC * delta
			$alien_pink.animation = 'walk'
		else:
			velocity.x = shift_towards(velocity.x, 0, FRICTION * delta)
			
		if Input.is_action_just_pressed('jump'):
			velocity.y = -JUMP
		#else:
			#velocity.x = lerp(velocity.x, 0, 0.3)
	else:
		$alien_pink.animation = 'jump'
		if Input.is_action_pressed('right'):
			velocity.x += AIR_ACC * delta
		elif Input.is_action_pressed('left'):
			velocity.x -= AIR_ACC * delta
		#velocity.x = lerp(velocity.x, 0, 0.3)
	
	var axis = -1
	var raw_axis = Input.get_axis("thrust2", "thrust")
	#var thrust = (Input.get_action_strength("thrust") - Input.get_action_strength("thrust2") + 1)/2
	if controller_trigger_pulled_at_least_once:
		axis = raw_axis
	elif raw_axis != 0:
		controller_trigger_pulled_at_least_once = true
		axis = raw_axis
		
	if axis > 0.1:
		jetpack_state = JetpackState.RISE
	elif axis > -0.9:
		jetpack_state = JetpackState.HOVER
	else:
		jetpack_state = JetpackState.OFF
		
	#print(jetpack_state)
	#var min_thrust = 0.5
	#var max_thrust = 0.9
	#print(min_thrust)
	#if thrust > 0.0:
		#print("orig", thrust)
		#thrust = scale(thrust, 0.0, 1.0, min_thrust, max_thrust)
		#print("Scaled ",thrust)
	
	
	
	if Input.is_action_just_pressed("grapple"):
		var x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
		var y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		var v = Vector2(x, y)
		if v.length()>0.1:
			hook = Hook.instance()
			hook.length = ROPE_LENGTH
			hook.position = position
			hook.position.y -= 30
			get_node("/root/main").add_child(hook)
			var direction = v.normalized()
			hook.apply_central_impulse(direction*1000)
		else:
			hook = null
		

		
	if hook:
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
	
	
	#var t = Input.get_axis("thrust", "thrust2")
	#var t = Input.get_joy_axis(0,1)
	#t = scale(t, 1.0, -1.0, 0.0, 200.0)
	#if t > 50 && t < 150: t = 100
	#print(t)
#	if thrust > -1.0:
#		var scaled_thrust = scale(thrust, -1.0, 1.0, 1.0, 1.03)
#		scaled_thrust = pow(scaled_thrust, 5)
#		print(scaled_thrust)
#		velocity.y -= (GRAVITY*scaled_thrust) * delta
	velocity.y += GRAVITY * delta
	if jetpack_state == JetpackState.HOVER:
		if velocity.y < 0:
			jetpack_state = JetpackState.OFF
		else:
			jetpack_state = JetpackState.RISE
		#velocity.y = shift_towards(velocity.y, 0, THURST * delta)
	if jetpack_state == JetpackState.RISE:
		velocity.y -= THURST * delta
	#velocity.y += -t * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	#if jump_timer > 0:
	#	jump_timer -= delta
	#	if Input.is_action_just_pressed('jump'):
	#		velocity.y = -200
	#		if not $phaseJump1.playing: $phaseJump1.play()

	#if is_on_floor():
	#velocity.x = clamp(velocity.x, -200, 200)
	#velocity.y = clamp(velocity.y, -200, 200)
	#else:
	#	velocity.x = clamp(velocity.x, -800, 800)
		#velocity.y = clamp(velocity.y, -800, 800)
	$alien_pink.flip_h = velocity.x < 0
	
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
