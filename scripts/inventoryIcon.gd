extends TextureButton

var id = 0
var clickable = false
var inventoryLoc = ".."
var mainLoc = ".."
var type = "i"
var made = false
var mouseIn = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current
	if ["ft","fb","fr"].has(type):
		current = get_node(mainLoc).currentFurnace
	elif ["sc"].has(type):
		current = get_node(mainLoc).currentChest
	match type:
		"icr":
			if get_node("..").made and !get_node("../../craftingTable").visible:
				visible = true
				clickable = true
				texture_normal = get_node(inventoryLoc).textures[get_node("..").recipes[get_node("..").crafted][1][0]]
				$Label.text = str(get_node("..").recipes[get_node("..").crafted][1][1])
			else:
				texture_normal = null
				clickable = false
				$Label.text = ""
		"ctr":
			if get_node("../../Inventory").made and get_node("..").visible:
				visible = true
				clickable = true
				texture_normal = get_node(inventoryLoc).textures[get_node("../../Inventory").recipes[get_node("../../Inventory").crafted][1][0]]
				$Label.text = str(get_node("../../Inventory").recipes[get_node("../../Inventory").crafted][1][1])
				rect_scale = Vector2(1.2,1.2)
			else:
				clickable = false
				texture_normal = null
				$Label.text = ""
		"ft":
			if get_node("..").visible and current[0][0] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][0]]
				$Label.text = str(current[1][0])
			else:
				texture_normal = null
				$Label.text = ""
		"fb":
			if get_node("..").visible and current[0][1] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][1]]
				$Label.text = str(current[1][1])
			else:
				texture_normal = null
				$Label.text = ""
		"fr":
			if get_node("..").visible and current[0][2] > 0:
				visible = true
				texture_normal = get_node(inventoryLoc).textures[current[0][2]]
				$Label.text = str(current[1][2])
				clickable = true
			else:
				clickable = false
				texture_normal = null
				$Label.text = ""
		"sc":
			if get_node("..").visible and current[0][id] > 0:
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
	if get_node("..").visible and clickable and mouseIn:
		if Input.is_action_pressed("jump"):
			get_node(mainLoc).icon_clicked(id,type,"right",true)
		elif Input.is_action_just_pressed("build"):
			get_node(mainLoc).icon_clicked(id,type,"right")

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
		get_node(mainLoc).icon_clicked(id,type,"left")

func _on_inventoryIcon_mouse_entered():
	mouseIn = true

func _on_inventoryIcon_mouse_exited():
	mouseIn = false
