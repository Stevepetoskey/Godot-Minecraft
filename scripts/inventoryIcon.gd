extends TextureButton

var loc = 0
var type = "inventory"
var mouseIn

onready var main

func _ready():
	var slot = main.inventory
	match type:
		"inventoryCraft":
			slot = main.inventoryCraft
		"craftingTable":
			slot = main.craftingTable
		"furnace":
			slot = main.currentFurnace
		"chest":
			slot = main.currentChest
	visible = true

func _process(delta):
	if main.visible:
		var slot = main.inventory
		match type:
			"inventoryCraft":
				slot = main.inventoryCraft
			"craftingTable":
				slot = main.craftingTable
			"furnace","furnaceResult":
				slot = main.currentFurnace
			"chest":
				slot = main.currentChest
		match type:
			"inventory","inventoryCraft","craftingTable":
				if slot[loc]["id"] != 0:
					texture_normal = main.get_node("../hotbar").textures[slot[loc]["id"]]
					$Label.show()
					$Label.text = str(slot[loc]["amount"])
				else:
					texture_normal = null
					$Label.hide()
			"inventoryCraftResult","craftingTableResult":
				if main.made:
					texture_normal = main.get_node("../hotbar").textures[main.recipes[main.crafted][1][0]]
					$Label.text = str(main.recipes[main.crafted][1][1])
					$Label.show()
				else:
					texture_normal = null
					$Label.hide()
			"furnace","furnaceResult":
				if main.get_node("../furnace").visible and slot[loc]["id"] != 0:
					texture_normal = main.get_node("../hotbar").textures[slot[loc]["id"]]
					$Label.text = str(slot[loc]["amount"])
					$Label.show()
				else:
					texture_normal = null
					$Label.hide()
			"chest":
				if main.get_node("../chestSmall").visible and slot[loc]["id"] != 0:
					texture_normal = main.get_node("../hotbar").textures[slot[loc]["id"]]
					$Label.text = str(slot[loc]["amount"])
					$Label.show()
				else:
					texture_normal = null
					$Label.hide()
		if Input.is_action_just_pressed("build") and mouseIn and !["inventoryCraftResult","craftingTableResult"].has(type):
			if main.holding:
				if type != "furnaceResult" and (slot[loc]["id"] == main.holdingData["id"] or slot[loc]["id"] == 0) and slot[loc]["amount"] < 64:
					slot[loc]["id"] = main.holdingData["id"]
					slot[loc]["amount"] += 1
					main.holdingData["amount"] -= 1
					if main.holdingData["amount"] <= 0:
						main.holding = false
			elif slot[loc]["id"] != 0:
				var amount = round(slot[loc]["amount"]/2.0)
				slot[loc]["amount"] -= amount
				main.holdingData = {"id":slot[loc]["id"],"amount":amount,"data":slot[loc]["data"]}
				main.holding = true
				if slot[loc]["amount"] <= 0:
					slot[loc]["id"] = 0
			if ["craftingTable","inventoryCraft"].has(type):
				main.check_crafting()
			elif ["furnaceResult","furnace"].has(type):
				main.emit_signal("updateFurnace")

func _on_inventoryIcon_pressed():
	var slot = main.inventory
	match type:
		"inventoryCraft":
			slot = main.inventoryCraft
		"craftingTable":
			slot = main.craftingTable
		"furnace","furnaceResult":
			slot = main.currentFurnace
		"chest":
			slot = main.currentChest
	if !["inventoryCraftResult","craftingTableResult"].has(type):
		if main.holding and type != "furnaceResult":
			if slot[loc]["id"] != main.holdingData["id"]:
				var replace = slot[loc]
				slot[loc] = main.holdingData
				if replace["id"] != 0:
					main.holdingData = replace
				else:
					main.holding = false
			else:
				if slot[loc]["amount"] + main.holdingData["amount"] <= 64:
					slot[loc]["amount"] += main.holdingData["amount"]
					main.holding = false
				else:
					main.holdingData["amount"] -= 64-slot[loc]["amount"]
					slot[loc]["amount"] = 64
		elif !main.holding and slot[loc]["id"] != 0:
			main.holdingData = slot[loc]
			main.holding = true
			slot[loc] = {"id":0,"amount":0,"data":{}}
		if ["craftingTable","inventoryCraft"].has(type):
			main.check_crafting()
		elif ["furnaceResult","furnace"].has(type):
			main.emit_signal("updateFurnace")
	elif main.made and (!main.holding or main.holdingData["id"] == main.recipes[main.crafted][1][0]):
		if type == "inventoryCraftResult":
			for i in range(4):
				if main.inventoryCraft[i]["id"] > 0:
					main.inventoryCraft[i]["amount"] -= 1
					if main.inventoryCraft[i]["amount"] <= 0:
						main.inventoryCraft[i] = {"id":0,"amount":0,"data":{}}
		else:
			for i in range(9):
				if main.craftingTable[i]["id"] > 0:
					main.craftingTable[i]["amount"] -= 1
					if main.craftingTable[i]["amount"] <= 0:
						main.craftingTable[i] = {"id":0,"amount":0,"data":{}}
		if !main.holding:
			main.holdingData = {"id":main.recipes[main.crafted][1][0],"amount":main.recipes[main.crafted][1][1],"data":{}}
			main.holding = true
		else:
			main.holdingData["amount"] += main.recipes[main.crafted][1][1]
		main.check_crafting()

func _on_inventoryIcon_mouse_entered():
	mouseIn = true

func _on_inventoryIcon_mouse_exited():
	mouseIn = false
