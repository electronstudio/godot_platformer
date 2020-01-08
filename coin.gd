extends Area2D

func _on_coin_body_entered(body):
	hide()
	$powerUp5.play()
	get_node("/root/main/HUD").inc_score()
	yield(get_tree().create_timer(2.0), "timeout")
	queue_free()
