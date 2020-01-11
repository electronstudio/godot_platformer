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
	