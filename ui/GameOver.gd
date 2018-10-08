extends MarginContainer

signal try_again

func _ready():
	pass

func win(money, high_score, high_score_money):
	if high_score:
		$VBoxContainer/Outcome.text = "Congratulations! New high score!"
	else:
		$VBoxContainer/Outcome.text = "Congratulations!"
	$VBoxContainer/HighScore.text = "Current high score: %s" % high_score_money
	$VBoxContainer/Reason.text = "You collected $%s for your Prince!" % money

func lose():
	$VBoxContainer/HighScore.hide()
	$VBoxContainer/Outcome.text = "Game Over!"
	$VBoxContainer/Reason.text = "You're effectiveness was reduced to 0!"

func _on_TryAgainButton_pressed():
	print('try again')
	get_tree().paused = false
	emit_signal('try_again')

func _on_QuitButton_pressed():
	get_tree().quit()
