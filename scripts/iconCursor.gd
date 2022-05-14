extends Sprite

var itemID = 0
var itemNum = 0

func _process(delta):
	global_position = get_global_mouse_position()
	if itemID > 0:
		texture = get_node("../../hotbar").textures[itemID]
		$Label.text = str(itemNum)
	else:
		$Label.text = ""
