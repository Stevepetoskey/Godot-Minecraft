extends TextureButton

var id = 0
var clickable = false
var inventoryLoc = ".."
var type = "i"
var made = false
var mouseIn = false

onready var main
onready var inventory = get_node("../../Inventory")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current
	if ["ft","fb","fr"].has(type):
		current = main.currentFurnace
	elif ["sc"].has(type):
		current = main.currentChest
	match type:
		"icr":
			if main.made and !get_node("../../../craftingTable").visible:
				visible = true
				clickable = true
				texture_normal = get_node(inventoryLoc).textures[main.recipes[main.crafted][1][0]]
				$Label.text = str(main.recipes[main.crafted][1][1])
			else:
				texture_normal = null
				clickable = false
				$Label.text = ""
		"ctr":
			if inventory.made and main.visible:
				visible = true
				clickable = true
				texture_normal = get_node(inventoryLoc).textures[inventory.recipes[inventory.crafted][1][0]]
				$Label.text = str(inventory.recipes[inventory.crafted][1][1])
				rect_scale = Vector2(1.2,1.2)
			else:
				clickable = false
				texture_normal = null
				$Label.text = ""
		"ft":
			if main.visible and current[0][0] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][0]]
				$Label.text = str(current[1][0])
			else:
				texture_normal = null
				$Label.text = ""
		"fb":
			if main.visible and current[0][1] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][1]]
				$Label.text = str(current[1][1])
			else:
				texture_normal = null
				$Label.text = ""
		"fr":
			if main.visible and current[0][2] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][2]]
				$Label.text = str(current[1][2])
				clickable = true
			else:
				clickable = false
				texture_normal = null
				$Label.text = ""
		"sc":
			if main.visible and current[0][id] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][id]]
				$Label.text = str(current[1][id])
			else:
				texture_normal = null
				$Label.text = ""
		_:
			var place = get_node(inventoryLoc).inventory
			match type:
				"ic":
					place = get_node(inventoryLoc).inventoryCraft
				"ct":
					place = get_node(inventoryLoc).craftingTable
			if place[0][id] == 0:
				texture_normal = null
				$Label.text = ""
			else:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[place[0][id]]
				$Label.text = str(place[1][id])
	print(type)
	if main.visible and clickable and mouseIn:
		if Input.is_action_pressed("jump"):
			main.icon_clicked(id,type,"right",true)
		elif Input.is_action_just_pressed("build"):
			main.icon_clicked(id,type,"right")

func _ready():
	visible = true

func _on_inventoryIcon_pressed():
	if clickable:
		if type == "icr":
			for i in range(4):
				if get_node(inventoryLoc).inventoryCraft[0][i] > 0:
					get_node(inventoryLoc).inventoryCraft[1][i] -= 1
					if get_node(inventoryLoc).inventoryCraft[1][i] <= 0:
						get_node(inventoryLoc).inventoryCraft[0][i] = 0 
		elif type == "ctr":
			for i in range(9):
				if get_node(inventoryLoc).craftingTable[0][i] > 0:
					get_node(inventoryLoc).craftingTable[1][i] -= 1
					if get_node(inventoryLoc).craftingTable[1][i] <= 0:
						get_node(inventoryLoc).craftingTable[0][i] = 0 
#		if ["ft","fb","fr"].has(type):
#			get_node(mainLoc).icon_clicked(id,type,"left",)
		main.icon_clicked(id,type,"left")

func _on_inventoryIcon_mouse_entered():
	mouseIn = true

func _on_inventoryIcon_mouse_exited():
	mouseIn = false
