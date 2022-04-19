extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var attached = false
var length = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_hook_body_entered(body):
	print("hooked")
	mode = RigidBody2D.MODE_STATIC
	sleeping = true
	attached = true
	var player = get_node("/root/main/player")
	length = position.distance_to(player.position)
	print("HOOKED WITH LENGTH "+str(length))
