extends TextureButton

var loc = 0

onready var inventory = get_node("../../Inventory")

func _process(delta):
	if inventory.inventory[loc]["id"] != 0:
		texture_normal = get_node("..").textures[inventory.inventory[loc]["id"]]
		$Label.show()
		$Label.text = str(inventory.inventory[loc]["amount"])
	else:
		texture_normal = null
		$Label.hide()
