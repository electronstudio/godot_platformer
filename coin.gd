extends Area2D

var collected=false

func _on_coin_body_entered(body):
	if collected:
		return
	collected=true
	hide()
	$powerUp5.play()
	if body==get_node("/root/main/player"):
		print("p1 coin")
		get_node("/root/main/HUD").inc_score()
	if body==get_node("/root/main/player2"):
		print("p2 coin")
		get_node("/root/main/HUD").inc_score2()
	yield(get_tree().create_timer(2.0), "timeout")
	
