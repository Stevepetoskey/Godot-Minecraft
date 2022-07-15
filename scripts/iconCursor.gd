extends Sprite

var itemID = 0
var itemNum = 0

onready var main = get_node("..")

func _process(delta):
	if main.holding:
		global_position = get_global_mouse_position()
		show()
		texture = get_node("../../hotbar").textures[main.holdingData["id"]]
		$Label.text = str(main.holdingData["amount"])
	else:
		hide()
