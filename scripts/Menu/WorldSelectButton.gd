extends Control

var on = false

func _on_Back_pressed():
	if on:
		get_node("../../../..")._on_play_pressed()
	else:
		get_node("../../../..").worldPathSelected = $DisplayName.text
		get_node("../../../play").disabled = false
		get_node("../../../Delete").disabled = false
		on = true
		for panel in get_node("../..").get_children():
			for child in panel.get_children():
				if child != self:
					child.get_node("Back").pressed = false
					child.on = false
