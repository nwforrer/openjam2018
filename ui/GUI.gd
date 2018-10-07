extends MarginContainer

func _ready():
	pass

func _on_Game_update_money(money):
	$HBoxContainer/Counters/MoneyCount/Background/Label.text = str(money)

func _on_Game_update_awareness(awareness):
	$HBoxContainer/Bars/HBoxContainer/Awareness/ProgressBar.value = awareness


func _on_Game_update_effectiveness(effectiveness):
	$HBoxContainer/Bars/HBoxContainer2/Effectiveness/ProgressBar.value = effectiveness
