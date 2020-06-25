extends CanvasLayer

var score = 0
var score2 = 0

func inc_score():
	set_score(score + 1)
	
func set_score(s):
	score = s
	$score.set_text(str(score))

func inc_score2():
	set_score2(score2 + 1)
	
func set_score2(s):
	score2 = s
	$score2.set_text(str(score2))


func _on_left_button_pressed():
	Input.action_press("left")

func _on_left_button_released():
	Input.action_release("left")

func _on_right_button_pressed():
	Input.action_press("right")

func _on_right_button_released():
	Input.action_release("right")

func _on_jump_button_pressed():
	Input.action_press("jump")

func _on_jump_button_released():
	Input.action_release("jump")



