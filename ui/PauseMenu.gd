extends MarginContainer

signal try_again

func _ready():
	$HowToScreen.hide()
	
func _on_TryAgainButton_pressed():
	get_tree().paused = false
	emit_signal('try_again')

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_ContinueButton_pressed():
	get_tree().paused = false
	hide()


func _on_HelpButton_pressed():
	$HowToScreen.show()
