extends MarginContainer

signal try_again

func _ready():
	pass

func _on_TryAgainButton_pressed():
	print('try again')
	get_tree().paused = false
	emit_signal('try_again')

func _on_QuitButton_pressed():
	get_tree().quit()
