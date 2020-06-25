extends KinematicBody2D

var velocity = Vector2(0,0)
var jump_timer = 0


func _physics_process(delta):
	if is_on_floor():
		$alien_pink.animation = 'idle_front'
		jump_timer = 0.5
		if Input.is_action_pressed('right'):
			velocity.x += 30
			$alien_pink.animation = 'walk'
		elif Input.is_action_pressed("left"):
			velocity.x -= 30
			$alien_pink.animation = 'walk'
		else:
			velocity.x = lerp(velocity.x, 0, 0.1)
	else:
		$alien_pink.animation = 'jump'
		if Input.is_action_pressed('right'):
			velocity.x += 5
		elif Input.is_action_pressed('left'):
			velocity.x -= 5
		
	velocity.y += 20
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if jump_timer > 0:
		jump_timer -= delta
		if Input.is_action_pressed('jump'):
			velocity.y = -400
			if not $phaseJump1.playing: $phaseJump1.play()

	velocity.x = clamp(velocity.x, -400, 400)
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
