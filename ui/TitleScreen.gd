extends Control

func _ready():
	$HowToScreen.hide()
	
func _on_StartButton_pressed():
	get_tree().change_scene("res://Game.tscn")

func _on_HowToButton_pressed():
	$HowToScreen.show()

func _on_CreditsButton_pressed():
	pass # replace with function body

func _on_QuitButton_pressed():
	get_tree().quit()
