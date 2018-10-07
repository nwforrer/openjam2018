extends MarginContainer

func _ready():
	pass

func _on_Game_update_money(money):
	$HBoxContainer/Counters/MoneyCount/Background/Label.text = str(money)
