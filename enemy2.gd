extends KinematicBody2D

var direction = Vector2.LEFT
var velocity = Vector2(-50, 0)

export var SPEED = 50
export var health = 3
export var JUMP = 600
export var JUMP_CHANCE = 0.01

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += 20
	velocity.x = direction.x * SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() && randf()<JUMP_CHANCE:
		velocity.y = -JUMP
	
	if is_on_wall():
		direction = -direction
		
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider.has_method("kill"):
			collider.kill()

func kill():
	health = health - 1
	if health<=0:
		$pepSound3.play()
		direction = Vector2.ZERO
		$enemy.animation = 'dead'
		$collision_shape_2d.disabled = true
		get_node("/root/main/HUD").inc_score()
