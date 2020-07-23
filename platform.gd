extends KinematicBody2D

export var velocity = Vector2(100,0)
export var period = 5
var time = 0

func _process(delta):
	position += velocity * delta
	time += delta
	if time > period:
		time = 0
		velocity = -velocity
		
	#move_and_slide(Vector2.RIGHT*SPEED, Vector2.UP)
