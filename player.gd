extends KinematicBody2D

var velocity = Vector2(0,0)
var jump_timer = 0

const ROPE_LENGTH = 500.0
const GRAVITY = 100.0
const THURST = 6500.0

var Hook = preload("res://hook.tscn")
var hook

func scale(valueIn, baseMin,  baseMax, limitMin, limitMax):
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin

func _physics_process(delta):
	if is_on_floor():
		$alien_pink.animation = 'idle_front'
		jump_timer = 0.5
		if Input.is_action_pressed('right'):
			velocity.x += 100
			$alien_pink.animation = 'walk'
		elif Input.is_action_pressed("left"):
			velocity.x -= 100
			$alien_pink.animation = 'walk'
		else:
			velocity.x = lerp(velocity.x, 0, 0.3)
	else:
		$alien_pink.animation = 'jump'
		if Input.is_action_pressed('right'):
			velocity.x += 100
		elif Input.is_action_pressed('left'):
			velocity.x -= 100
		velocity.x = lerp(velocity.x, 0, 0.3)
		
	#var thrust = (Input.get_action_strength("thrust") - Input.get_action_strength("thrust2") + 1)/2
	var thrust = Input.get_action_strength("thrust") - Input.get_action_strength("thrust2")
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
	var t = Input.get_joy_axis(0,1)
	t = scale(t, 1.0, -1.0, 0.0, 200.0)
	if t > 50 && t < 150: t = 100
	print(t)
#	if thrust > -1.0:
#		var scaled_thrust = scale(thrust, -1.0, 1.0, 1.0, 1.03)
#		scaled_thrust = pow(scaled_thrust, 5)
#		print(scaled_thrust)
#		velocity.y -= (GRAVITY*scaled_thrust) * delta
	velocity.y += GRAVITY * delta
	velocity.y += -t * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if jump_timer > 0:
		jump_timer -= delta
		if Input.is_action_just_pressed('jump'):
			velocity.y = -200
			if not $phaseJump1.playing: $phaseJump1.play()

	#if is_on_floor():
		velocity.x = clamp(velocity.x, -200, 200)
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
