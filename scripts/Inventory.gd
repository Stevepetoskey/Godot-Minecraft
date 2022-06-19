extends Sprite

var holdingItem = false
var rightDown = false
var spaceUsed = []
var recipes = [[[[Vector2(0,0),4]],[8,4]],[[[Vector2(0,0),8],[Vector2(0,1),8]],[9,4]],
[[[Vector2(0,0),8],[Vector2(1,0),8],[Vector2(0,1),8],[Vector2(1,1),8]],[10,1]],
[[[Vector2(0, 0), 8], [Vector2(1, 0), 8], [Vector2(2, 0), 8], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[11,1]], #Wood tools
[[[Vector2(0, 0), 8], [Vector2(1, 0), 8], [Vector2(0, 1), 8], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[12,1]],
[[[Vector2(0, 0), 8], [Vector2(1, 0), 8], [Vector2(0, 1), 9], [Vector2(1, 1), 8], [Vector2(0, 2), 9]],[12,1]],
[[[Vector2(0, 0), 8], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [14, 1]],
[[[Vector2(0, 0), 8], [Vector2(0, 1), 8], [Vector2(0, 2), 9]], [16, 1]],
[[[Vector2(0, 0), 8], [Vector2(1, 0), 8], [Vector2(1, 1), 9], [Vector2(1, 2), 9]], [17, 1]],
[[[Vector2(0, 0), 8], [Vector2(1, 0), 8], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [17, 1]],
[[[Vector2(0, 0), 13], [Vector2(1, 0), 13], [Vector2(2, 0), 13], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[18,1]], #Stone tools
[[[Vector2(0, 0), 13], [Vector2(1, 0), 13], [Vector2(0, 1), 13], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[19,1]],
[[[Vector2(0, 0), 13], [Vector2(1, 0), 13], [Vector2(0, 1), 9], [Vector2(1, 1), 13], [Vector2(0, 2), 9]],[19,1]],
[[[Vector2(0, 0), 13], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [20, 1]],
[[[Vector2(0, 0), 13], [Vector2(0, 1), 13], [Vector2(0, 2), 9]], [21, 1]],
[[[Vector2(0, 0), 13], [Vector2(1, 0), 13], [Vector2(1, 1), 9], [Vector2(1, 2), 9]], [22, 1]],
[[[Vector2(0, 0), 13], [Vector2(1, 0), 13], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [22, 1]],
[[[Vector2(0, 0), 24], [Vector2(1, 0), 24], [Vector2(2, 0), 24], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[29,1]], #Iron Tools
[[[Vector2(0, 0), 24], [Vector2(1, 0), 24], [Vector2(0, 1), 24], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[30,1]],
[[[Vector2(0, 0), 24], [Vector2(1, 0), 24], [Vector2(0, 1), 9], [Vector2(1, 1), 24], [Vector2(0, 2), 9]],[30,1]],
[[[Vector2(0, 0), 24], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [31, 1]],
[[[Vector2(0, 0), 24], [Vector2(0, 1), 24], [Vector2(0, 2), 9]], [32, 1]],
[[[Vector2(0, 0), 24], [Vector2(1, 0), 24], [Vector2(1, 1), 9], [Vector2(1, 2), 9]], [33, 1]],
[[[Vector2(0, 0), 24], [Vector2(1, 0), 24], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [33, 1]],
[[[Vector2(0, 0), 13], [Vector2(1, 0), 13], [Vector2(2, 0), 13], [Vector2(0, 1), 13], [Vector2(2, 1), 13], [Vector2(0, 2), 13], [Vector2(1, 2), 13], [Vector2(2, 2), 13]], [23, 1]],#Furnace
[[[Vector2(0, 0), 15], [Vector2(1, 0), 15], [Vector2(2, 0), 15], [Vector2(0, 1), 15], [Vector2(1, 1), 15], [Vector2(2, 1), 15], [Vector2(0, 2), 15], [Vector2(1, 2), 15], [Vector2(2, 2), 15]], [25, 1]],#coal block
[[[Vector2(0, 0),24],[Vector2(1, 0),24],[Vector2(2, 0),24],[Vector2(0, 1),24],[Vector2(1, 1),24],[Vector2(2, 1),24],[Vector2(0, 2),24],[Vector2(1, 2),24],[Vector2(2, 2),24]], [26, 1]], #iron block
[[[Vector2(0, 0), 34], [Vector2(1, 0), 34], [Vector2(2, 0), 34], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[36,1]], #Diamond pick
[[[Vector2(0, 0), 34], [Vector2(1, 0), 34], [Vector2(0, 1), 34], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[37,1]], #Diamond axe
[[[Vector2(0, 0), 34], [Vector2(1, 0), 34], [Vector2(0, 1), 9], [Vector2(1, 1), 34], [Vector2(0, 2), 9]],[37,1]], #Diamond axe
[[[Vector2(0, 0), 34], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [38, 1]], #Diamond shovel
[[[Vector2(0, 0), 34], [Vector2(0, 1), 34], [Vector2(0, 2), 9]], [39, 1]], #Diamond sword
[[[Vector2(0, 0), 34], [Vector2(1, 0), 34], [Vector2(1, 1), 9], [Vector2(1, 2), 9]], [40, 1]], #Diamond hoe
[[[Vector2(0, 0), 34], [Vector2(1, 0), 34], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [40, 1]], #Diamond hoe
[[[Vector2(0, 0),42],[Vector2(1, 0),42],[Vector2(0, 1),42],[Vector2(1, 1),42]], [44, 1]], #Sandstone
[[[Vector2(0, 0),47],[Vector2(1, 0),47],[Vector2(0, 1),47],[Vector2(1, 1),47]], [48, 1]], #Clay block
[[[Vector2(0, 0),49],[Vector2(1, 0),49],[Vector2(0, 1),49],[Vector2(1, 1),49]], [50, 1]], #Bricks
[[[Vector2(0, 0),3],[Vector2(1, 0),3],[Vector2(0, 1),3],[Vector2(1, 1),3]], [52, 4]], #Stone bricks
[[[Vector2(0, 0),15],[Vector2(0, 1),9]], [53, 4]], #Torches
[[[Vector2(0, 0),9],[Vector2(2, 0),9],[Vector2(0, 1),9],[Vector2(1, 1),9],[Vector2(2, 1),9],[Vector2(0, 2),9],[Vector2(2, 2),9]], [54, 4]], #Ladder
[[[Vector2(0, 0),8],[Vector2(1, 0),8],[Vector2(2, 0),8],[Vector2(0, 1),8],[Vector2(2, 1),8],[Vector2(0, 2),8],[Vector2(1, 2),8],[Vector2(2, 2),8]], [58, 1]], #Chest
[[[Vector2(0, 0),24],[Vector2(2, 0),24],[Vector2(1, 1),24]], [59, 1]], #Bucket
[[[Vector2(0, 0),8],[Vector2(1, 0),8],[Vector2(0, 1),8],[Vector2(1, 1),8],[Vector2(0, 2),8],[Vector2(1, 2),8]], [62, 3]], #Oak door
] #[[item1[pos (to orgin),id],item2,ect],[result id,result num]]
var crafted = 0
var made = false
var currentFurnace
var currentChest

signal updateFurnace

func _ready():
	#main inventory
	var loc = 0
	for y in range(3,-1,-1):
		for x in range(9):
			var icon = load("res://assets/inventoryIcon.tscn").instance()
			icon.id = loc
			if loc < 9:
				icon.rect_position = Vector2(x*18-79,y*18+6)
			else:
				icon.rect_position = Vector2(x*18-79,y*18+2)
			icon.clickable = true
			icon.inventoryLoc = "../../hotbar"
			add_child(icon)
			loc += 1
	#inventory crafting
	loc = 0
	for y in range(2):
		for x in range(2):
			var icon = load("res://assets/inventoryIcon.tscn").instance()
			icon.id = loc
			icon.type = "ic"
			icon.rect_position = Vector2(x*18+11,y*18-64)
			icon.clickable = true
			icon.inventoryLoc = "../../hotbar"
			add_child(icon)
			loc += 1
	#inventory crafting result
	var icon = load("res://assets/inventoryIcon.tscn").instance()
	icon.id = 0
	icon.type = "icr"
	icon.rect_position = Vector2(66.5,-54)
	icon.clickable = true
	icon.inventoryLoc = "../../hotbar"
	icon.texture_normal = load("res://textures/Blocks/bedrock.png")
	add_child(icon)
	#crafting table
	loc = 0
	for y in range(3):
		for x in range(3):
			var tableIcon = load("res://assets/inventoryIcon.tscn").instance()
			tableIcon.id = loc
			tableIcon.type = "ct"
			tableIcon.mainLoc = "../../Inventory"
			tableIcon.rect_position = Vector2(x*18+31,y*18+17.5)
			tableIcon.clickable = true
			tableIcon.inventoryLoc = "../../hotbar"
			get_node("../craftingTable").add_child(tableIcon)
			loc += 1
	var tableIcon = load("res://assets/inventoryIcon.tscn").instance()
	tableIcon.id = 0
	tableIcon.type = "ctr"
	tableIcon.mainLoc = "../../Inventory"
	tableIcon.rect_position = Vector2(122,34)
	tableIcon.clickable = true
	tableIcon.inventoryLoc = "../../hotbar"
	get_node("../craftingTable").add_child(tableIcon)
	#furnace
	for i in range(3):
		var furnaceIcon = load("res://assets/inventoryIcon.tscn").instance()
		furnaceIcon.id = i
		match i:
			0:
				furnaceIcon.type = "ft"
				furnaceIcon.rect_position = Vector2(57,18)
			1:
				furnaceIcon.type = "fb"
				furnaceIcon.rect_position = Vector2(57,54)
			2:
				furnaceIcon.type = "fr"
				furnaceIcon.rect_position = Vector2(115,34)
				furnaceIcon.rect_scale = Vector2(1.2,1.2)
		furnaceIcon.mainLoc = "../../Inventory"
		furnaceIcon.clickable = true
		furnaceIcon.inventoryLoc = "../../hotbar"
		get_node("../furnace").add_child(furnaceIcon)
	#small chest
	loc = 0
	for y in range(3):
		for x in range(9):
			var chestIcon = load("res://assets/inventoryIcon.tscn").instance()
			chestIcon.id = loc
			chestIcon.type = "sc"
			chestIcon.mainLoc = "../../Inventory"
			chestIcon.rect_position = Vector2(x*18+9,y*18+19)
			chestIcon.clickable = true
			chestIcon.inventoryLoc = "../../hotbar"
			get_node("../chestSmall").add_child(chestIcon)
			loc += 1

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if visible:
			get_node("../craftingTable").visible = false
			get_node("../furnace").visible = false
			if get_node("../chestSmall").visible:
				var cursor = get_node("../../cursor")
				get_node("../../chunks").get_node(str(get_node("../..").get_chunk(cursor.position.x/16))).get_node(str(cursor.z) + "," + str(get_node("../..").chunkifyI(cursor.position.x/16)) + "," + str(cursor.position.y/16)).interact(false)
			get_node("../chestSmall").visible = false
		visible = !visible
		if holdingItem:
			get_node("../../entities").add_item($iconCursor.itemID,$iconCursor.itemNum,get_node("../../Player").position,true)
			holdingItem = false
			$iconCursor.visible = false
			$iconCursor.itemNum = 0
			$iconCursor.itemID = 0
		var invCraft = get_node("../hotbar").inventoryCraft
		for i in range(invCraft[0].size()):
			if invCraft[0][i] > 0:
				get_node("../../entities").add_item(invCraft[0][i],invCraft[1][i],get_node("../../Player").position,true)
				invCraft[0][i] = 0
				invCraft[1][i] = 0
	$iconCursor.visible = holdingItem
#	if Input.is_action_just_released("jump"):
#		rightDown = false
#		spaceUsed = []

func remove_item(array,id,amount):
	if array[1][id]-amount< 1:
		array[1][id] = 0
		array[0][id] = 0
	else:
		array[1][id] -= amount

func icon_clicked(id,type,click,hold=false,pos=Vector2(0,0)):
	if !rightDown or (rightDown and !spaceUsed.has([id,type])):
		if hold:
			rightDown = true
			spaceUsed.append([id,type])
		else:
			rightDown = false
			spaceUsed = []
		var selected = get_node("../hotbar").inventory
		match type:
			"ic":
				selected = get_node("../hotbar").inventoryCraft
			"icr", "ctr":
				selected = recipes[crafted][1]
			"ct":
				selected = get_node("../hotbar").craftingTable
			"ft","fb","fr":
				selected = currentFurnace
			"sc":
				selected = currentChest
		if holdingItem:
			if ["icr","ctr"].has(type) and $iconCursor.itemID == selected[0] and click != "right":
				if $iconCursor.itemNum + selected[1] > 64:
					$iconCursor.itemNum = 64
					selected[1] -= 64-$iconCursor.itemNum
				else:
					$iconCursor.itemNum += selected[1]
			elif !["icr","ctr"].has(type) and type == "fr" and selected[0][id] > 0 and $iconCursor.itemID == selected[0][id]:
				if $iconCursor.itemNum + selected[1][id] > 64:
					$iconCursor.itemNum = 64
					remove_item(selected,id,64-$iconCursor.itemNum)
				else:
					$iconCursor.itemNum += selected[1][id]
					remove_item(selected,id,selected[1][id])
			elif !["icr","ctr","fr"].has(type):
				if selected[0][id] == $iconCursor.itemID and selected[0][id] > 0:
					if click == "left":
						if selected[1][id] + $iconCursor.itemNum > 64:
							$iconCursor.itemNum -= 64-selected[1][id]
							selected[1][id] = 64
						else:
							selected[1][id] += $iconCursor.itemNum
							holdingItem = false
					else:
						if selected[1][id] < 64:
							selected[1][id] += 1
							$iconCursor.itemNum -= 1
						if $iconCursor.itemNum <= 0:
							holdingItem = false
				else:
					if click == "left":
						var replace = selected[0][id] > 0
						var itemID = selected[0][id]
						var itemNum = selected[1][id]
						selected[1][id] = $iconCursor.itemNum
						selected[0][id] = $iconCursor.itemID
						holdingItem = false
						if replace:
							$iconCursor.itemNum = itemNum
							$iconCursor.itemID = itemID
							holdingItem = true
					elif selected[0][id] == 0:
						selected[0][id] = $iconCursor.itemID
						selected[1][id] = 1
						$iconCursor.itemNum -= 1
						if $iconCursor.itemNum <= 0:
							holdingItem = false
		else:
			if click == "left":
				if ["icr","ctr"].has(type):
					$iconCursor.itemID = selected[0]
					$iconCursor.itemNum = selected[1]
					holdingItem = true
				elif type == "fr":
					$iconCursor.itemID = selected[0][2]
					$iconCursor.itemNum = selected[1][2]
					selected[0][2] = 0
					selected[1][2] = 0
					holdingItem = true
				elif selected[0][id] > 0:
					$iconCursor.itemID = selected[0][id]
					$iconCursor.itemNum = selected[1][id]
					selected[1][id] = 0
					selected[0][id] = 0
					holdingItem = true
			elif !["icr","ctr","fr"].has(type):
				$iconCursor.itemID = selected[0][id]
				$iconCursor.itemNum = ceil(selected[1][id]/2.0)
				selected[1][id] = floor(selected[1][id]/2.0)
				if selected[1][id] <= 0:
					selected[0][id] = 0
				holdingItem = true
		if ["ft","fb","fr"].has(type):
			emit_signal("updateFurnace")
		check_crafting()

func check_crafting():
	var craft = get_node("../hotbar").inventoryCraft
	var size = 2
	if get_node("../craftingTable").visible:
		craft = get_node("../hotbar").craftingTable
		size = 3
	var loc = 0
	var orgin = Vector2(-1,-1)
	var crafting = []
	for y in range(size):
		for x in range(size):
			if craft[0][loc] > 0 and orgin == Vector2(-1,-1):
				orgin = Vector2(x,y)
				crafting.append([Vector2(0,0),craft[0][loc]])
			elif craft[0][loc] > 0:
				crafting.append([Vector2(x,y)-orgin,craft[0][loc]])
			loc += 1
	if crafting == []:
		made = false
		return
	for i in range(recipes.size()):
		if recipes[i][0] == crafting:
			crafted = i
			made = true
			return
	made = false
