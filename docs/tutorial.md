## Godot

[Download Godot here](https://godotengine.org/download)

Or install it from the software centre on Linux.

### Import starter project

Download [godot_platformer1.zip](/godot_platformer1.zip) and unzip it.  In Godot file manager, select `import` and then select the `project.godot` file in `godot_platformer1`.

### Player

Add this code to `player.gd` file.

```
	if jump_timer > 0:
		jump_timer -= delta
		if Input.is_action_pressed('jump'):
			velocity.y = -400
			if not $phaseJump1.playing: $phaseJump1.play()

	#velocity.x = clamp(velocity.x, -400, 400)
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
```

Work out what each line does.

Q. How can you change the code to make the player jump higher?

Q. How can you make the player run faster?

Q. How can you make the player fall slower?

### The bee

The bee is harmless.  Take a look at its nodes.

Q. In the game, can you kick the bee?  How does it move when we have not written any code for it?

### Speed

Try adding this to the player.gd:

    velocity.x = clamp(velocity.x, -300, 300)

Q. What does it do?

### Scrolling

Add a Camera2d node as a child of player node.  Click Current->On to enable it.

### Map

Click the tilemap node and create your own level  Click left mouse to place a tile and right mouse to delete a tile (you can delete my tiles if you like).

### Parallax Scrolling Background

Add ParallaxBackground node to main scene.  Add ParallaxLayer as child node of this.  Set Motion->Scale->x to 0.5.  Set Motion->Mirroring-X to 1024.  Drag in an image, eg. backgroundCastles.png to the scene and drag it to become child of ParallaxLayer.

Q. What is Parallax?

### Coins

There is one coin node, an Area2d, already added for you.  It has a sound, image and collision shape but it doesn't have a script.  Right click it, select 'attach script', press 'Create'.  Delete all the code that is there and enter the new script code:
```
extends Area2D

func _on_coin_body_entered(body):
	hide()
	$powerUp5.play()
	get_node("/root/main/HUD").inc_score()
	yield(get_tree().create_timer(2.0), "timeout")
	queue_free()
```

### Instancing

Since we will have a lot of coins it makes sense to make the coin a separate scene and then instance this scene every time we want to make a coin. Right click the coin node, select 'save branch as scene', click 'save'.

Now right click on 'coins' node, select 'instance child scene' and select your coin.tscn scene.  Drag the coin to where you want it.

### Enemies

Click `Scene` menu, then `New Scene` then click `2D Scene` as the root node. 

Press ctrl-S to save the scene.  I'm making an ant enemy so I have named mine `ant.tscn`.

Right click on the root `node_2d`.  Click  `Change type`.  Find  `KinematicBody2d` (you can type the name) and double click it.  (You can also rename `node_2d` to `ant` if you want)

Now we need to add child notes to the root node.

1. In the filesystem, find `characters/enemies/ant.tscn`.  Drag it on the 0,0 point in the scene.  Click on it and in the Inspector tick `playing`.

2. Right-click `node_2d`, `Add Child Node`, select `collision shape 2d`.  In the Inspector click on the `[empty]` and select `new rectangleshape2d`.  Use the drag spots to increase the size of the rectangle.

3. Add another child node to `node_2d`.  This time select `VisibilityEnabler2d`.  In the inspector make sure ALL the boxes are ticked.

4. Right-click `node_2d`, select `merge from scene`.  Find `audio/digital_sfx.tscn` and double click it.  Then select `pepSound3` from the node list.  Press OK.

5. Right-click `node_2d`, select `attach script`.  Change the `Path` to `res://ant.gd`.  Press `Create`.  Copy the printout code into the script.


```
extends KinematicBody2D

var direction = Vector2.LEFT
var velocity = Vector2(-50, 0)

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += 20
	velocity.x = direction.x * 50
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_wall():
		direction = -direction
		
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider.has_method("kill"):
			collider.kill()

func kill():
	$pepSound3.play()
	direction = Vector2.ZERO
	$ant.animation = 'dead'
	$collision_shape_2d.disabled = true
	get_node("/root/main/HUD").inc_score()
```

Now we can switch back to our main scene and add enemies by dragging in `ant.tscn`.

## Homework

Add more tiles, coins and enemies to create a challenging game.  Also try adding a second player, or changing the player sprite to a different one.



