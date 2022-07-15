extends TextureButton

var id = 0

onready var inventory = get_node("../../../Inventory")

func _pressed():
	if inventory.holding and inventory.holdingData["id"] != id:
		inventory.holding = false
	else:
		if Input.is_action_pressed("actionClick"):
			inventory.holdingData = {"id":id,"amount":64,"data":{}}
			inventory.holding = true
		else:
			if !inventory.holding:
				inventory.holdingData = {"id":id,"amount":1,"data":{}}
				inventory.holding = true
			else:
				inventory.holdingData["amount"] += 1
