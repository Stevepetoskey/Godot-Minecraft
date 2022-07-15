extends Node2D

const ALL_PLANKS = -1
const PLANK_TYPES = [65,8,69]

var holding = false
var holdingData = {}
var rightDown = false
var spaceUsed = []
var recipes = [[[[Vector2(0,0),4]],[8,4]], #Oak log
[[[Vector2(0,0),-1],[Vector2(0,1),-1]],[9,4]],
[[[Vector2(0,0),-1],[Vector2(1,0),-1],[Vector2(0,1),-1],[Vector2(1,1),-1]],[10,1]], #Crafting table
[[[Vector2(0, 0), -1], [Vector2(1, 0), -1], [Vector2(2, 0), -1], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[11,1]], #Wood tools
[[[Vector2(0, 0), -1], [Vector2(1, 0), -1], [Vector2(0, 1), -1], [Vector2(1, 1), 9], [Vector2(1, 2), 9]],[12,1]],
[[[Vector2(0, 0), -1], [Vector2(1, 0), -1], [Vector2(0, 1), 9], [Vector2(1, 1), -1], [Vector2(0, 2), 9]],[12,1]],
[[[Vector2(0, 0), -1], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [14, 1]],
[[[Vector2(0, 0), -1], [Vector2(0, 1), -1], [Vector2(0, 2), 9]], [16, 1]],
[[[Vector2(0, 0), -1], [Vector2(1, 0), -1], [Vector2(1, 1), 9], [Vector2(1, 2), 9]], [17, 1]],
[[[Vector2(0, 0), -1], [Vector2(1, 0), -1], [Vector2(0, 1), 9], [Vector2(0, 2), 9]], [17, 1]],
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
[[[Vector2(0, 0),-1],[Vector2(1, 0),-1],[Vector2(2, 0),-1],[Vector2(0, 1),-1],[Vector2(2, 1),-1],[Vector2(0, 2),-1],[Vector2(1, 2),-1],[Vector2(2, 2),-1]], [58, 1]], #Chest
[[[Vector2(0, 0),24],[Vector2(2, 0),24],[Vector2(1, 1),24]], [59, 1]], #Bucket
[[[Vector2(0, 0),8],[Vector2(1, 0),8],[Vector2(0, 1),8],[Vector2(1, 1),8],[Vector2(0, 2),8],[Vector2(1, 2),8]], [62, 3]], #Oak door
[[[Vector2(0, 0),64]], [65, 4]], #Birch planks
[[[Vector2(0, 0),68]], [69, 4]], #Spruce planks
[[[Vector2(0, 0),75]], [76, 9]], #Golden nugget
[[[Vector2(0, 0),76],[Vector2(1, 0),76],[Vector2(2, 0),76],[Vector2(0, 1),76],[Vector2(1, 1),76],[Vector2(2, 1),76],[Vector2(0, 2),76],[Vector2(1, 2),76],[Vector2(2, 2),76]], [75, 1]], #Golden ingot
[[[Vector2(0, 0),75],[Vector2(1, 0),75],[Vector2(2, 0),75],[Vector2(0, 1),75],[Vector2(1, 1),75],[Vector2(2, 1),75],[Vector2(0, 2),75],[Vector2(1, 2),75],[Vector2(2, 2),75]], [73, 1]], #Block of Gold
[[[Vector2(0, 0),78],[Vector2(1, 0),78],[Vector2(2, 0),78],[Vector2(0, 1),78],[Vector2(1, 1),78],[Vector2(2, 1),78],[Vector2(0, 2),78],[Vector2(1, 2),78],[Vector2(2, 2),78]], [79, 1]], #Block of Lapis Lazuli
[[[Vector2(0, 0),83],[Vector2(1, 0),83],[Vector2(2, 0),83],[Vector2(0, 1),83],[Vector2(1, 1),83],[Vector2(2, 1),83],[Vector2(0, 2),83],[Vector2(1, 2),83],[Vector2(2, 2),83]], [84, 1]], #Redstone Block
[[[Vector2(0, 0),83],[Vector2(0, 1),9]], [80, 1]], #Redstone torch
[[[Vector2(0, 0),75],[Vector2(1, 0),75],[Vector2(2, 0),75],[Vector2(1, 1),9],[Vector2(1, 2),9]], [85, 1]], #Gold Pick
[[[Vector2(0, 0),75],[Vector2(1, 0),75],[Vector2(0, 1),75],[Vector2(1, 1),9],[Vector2(1, 2),9]], [86, 1]], #Gold axe
[[[Vector2(0, 0),75],[Vector2(1, 0),75],[Vector2(0, 1),9],[Vector2(1, 1),75],[Vector2(0, 2),9]], [86, 1]], #Gold axe mirror
[[[Vector2(0, 0),75],[Vector2(0, 1),9],[Vector2(0, 2),9]], [87, 1]], #Gold shovel
[[[Vector2(0, 0),75],[Vector2(0, 1),75],[Vector2(0, 2),9]], [88, 1]], #Gold sword
[[[Vector2(0, 0),75],[Vector2(1, 0),75],[Vector2(1, 1),9],[Vector2(1, 2),9]], [89, 1]], #Gold hoe
[[[Vector2(0, 0),75],[Vector2(1, 0),75],[Vector2(0, 1),9],[Vector2(0, 2),9]], [89, 1]], #Gold hoe mirror
[[[Vector2(0, 0),92],[Vector2(1, 0),92],[Vector2(2, 0),92]], [93, 1]], #bread
[[[Vector2(0, 0),52],[Vector2(-1, 1),52],[Vector2(0, 1),52],[Vector2(-2, 2),52],[Vector2(-1, 2),52],[Vector2(0, 2),52]], [97, 1]], #Stone Brick stairs
[[[Vector2(0, 0),52],[Vector2(0, 1),52],[Vector2(1, 1),52],[Vector2(0, 2),52],[Vector2(1, 2),52],[Vector2(2, 2),52]], [97, 1]], #Stone Brick stairs mirrored
] #[[item1[pos (to orgin),id],item2,ect],[result id,result num]]
var crafted = 0 #the recipe id
var made = false #wether a recipe has been made
var currentFurnace
var currentChest

var emptyItem = {"id":0,"amount":0,"data":{}}

var chestData = []

var inventory = []
var inventoryCraft = []
var craftingTable = []

onready var globals = get_node("/root/GlobalScript")

signal updateFurnace

func _ready():
	for i in range(27):
		chestData.append(emptyItem.duplicate(true))
	#hotbar
	for loc in range(9):
		var icon = load("res://assets/inventoryIcon.tscn").instance()
		icon.loc = loc
		icon.rect_position = Vector2(loc*18-79,59)
		icon.main = self
		icon.type = "inventory"
		$icons.add_child(icon)
	var iconId = 9
	#inventory
	for y in range(3):
		for x in range(9):
			var icon = load("res://assets/inventoryIcon.tscn").instance()
			icon.loc = iconId
			icon.rect_position = Vector2(x*18-79,y*18+2)
			icon.main = self
			icon.type = "inventory"
			$icons.add_child(icon)
			iconId += 1
	#inventory crafting
	iconId = 0
	for y in range(2):
		for x in range(2):
			inventoryCraft.append({"id":0,"amount":0,"data":{}})
			var icon = load("res://assets/inventoryIcon.tscn").instance()
			icon.loc = iconId
			icon.main = self
			icon.type = "inventoryCraft"
			icon.rect_position = Vector2(x*18+11,y*18-64)
			$icons.add_child(icon)
			iconId += 1
	#inventory crafting result
	var icon = load("res://assets/inventoryIcon.tscn").instance()
	icon.loc = 0
	icon.main = self
	icon.type = "inventoryCraftResult"
	icon.rect_position = Vector2(66.5,-54)
	$icons.add_child(icon)
	#crafting table
	iconId = 0
	for y in range(3):
		for x in range(3):
			craftingTable.append({"id":0,"amount":0,"data":{}})
			var tableIcon = load("res://assets/inventoryIcon.tscn").instance()
			tableIcon.loc = iconId
			tableIcon.type = "craftingTable"
			tableIcon.main = self
			tableIcon.rect_position = Vector2(x*18+31,y*18+17.5)
			get_node("../craftingTable").add_child(tableIcon)
			iconId += 1
	#crafting table result
	var tableIcon = load("res://assets/inventoryIcon.tscn").instance()
	tableIcon.loc = 0
	tableIcon.type = "craftingTableResult"
	tableIcon.main = self
	tableIcon.rect_position = Vector2(122,34)
	get_node("../craftingTable").add_child(tableIcon)
	#furnace
	for i in range(3):
		var furnaceIcon = load("res://assets/inventoryIcon.tscn").instance()
		furnaceIcon.loc = i
		match i:
			0:
				furnaceIcon.type = "furnace"
				furnaceIcon.rect_position = Vector2(57,18)
			1:
				furnaceIcon.type = "furnace"
				furnaceIcon.rect_position = Vector2(57,54)
			2:
				furnaceIcon.type = "furnaceResult"
				furnaceIcon.rect_position = Vector2(115,34)
				furnaceIcon.rect_scale = Vector2(1.2,1.2)
		furnaceIcon.main = self
		get_node("../furnace").add_child(furnaceIcon)
	#small chest
	iconId = 0
	for y in range(3):
		for x in range(9):
			var chestIcon = load("res://assets/inventoryIcon.tscn").instance()
			chestIcon.loc = iconId
			chestIcon.type = "chest"
			chestIcon.main = self
			chestIcon.rect_position = Vector2(x*18+9,y*18+19)
			get_node("../chestSmall").add_child(chestIcon)
			iconId += 1

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if visible:
			get_node("../craftingTable").hide()
			get_node("../furnace").hide()
			if get_node("../chestSmall").visible:
				var cursor = get_node("../../cursor")
				get_node("../../chunks").get_node(str(get_node("../..").get_chunk(cursor.position.x/16))).get_node(str(cursor.z) + "," + str(get_node("../..").chunkifyI(cursor.position.x/16)) + "," + str(cursor.position.y/16)).interact(false)
			get_node("../chestSmall").hide()
			$Inventory.show()
			$icons.show()
			get_node("../CI").hide()
		else:
			if globals.gamemode == "Creative":
				$Inventory.hide()
				$icons.hide()
				get_node("../CI").show()
		visible = !visible
		if holding:
			get_node("../../entities").add_item(holdingData["id"],holdingData["amount"],get_node("../../Player").position,true)
			holding = false
		for i in range(inventoryCraft.size()):
			if !inventoryCraft[i].empty():
				get_node("../../entities").add_item(inventoryCraft[i]["id"],inventoryCraft[i]["amount"],get_node("../../Player").position,true)
				inventoryCraft[i] = emptyItem.duplicate(true)
		for i in range(craftingTable.size()):
			if !craftingTable[i].empty():
				get_node("../../entities").add_item(craftingTable[i]["id"],craftingTable[i]["amount"],get_node("../../Player").position,true)
				craftingTable[i] = emptyItem.duplicate(true)

func check_crafting():
	var craft = inventoryCraft
	var size = 2
	if get_node("../craftingTable").visible:
		craft = craftingTable
		size = 3
	var loc = 0
	var orgin = Vector2(-1,-1)
	var crafting = []
	var craftingAll = []
	for y in range(size):
		for x in range(size):
			if craft[loc]["id"] > 0 and orgin == Vector2(-1,-1):
				orgin = Vector2(x,y)
				crafting.append([Vector2(0,0),craft[loc]["id"]])
				if PLANK_TYPES.has(craft[loc]["id"]):
					craftingAll.append([Vector2(0,0),ALL_PLANKS])
				else:
					craftingAll.append([Vector2(0,0),craft[loc]["id"]])
			elif craft[loc]["id"] > 0:
				crafting.append([Vector2(x,y)-orgin,craft[loc]["id"]])
				if PLANK_TYPES.has(craft[loc]["id"]):
					craftingAll.append([Vector2(x,y)-orgin,ALL_PLANKS])
				else:
					craftingAll.append([Vector2(x,y)-orgin,craft[loc]["id"]])
			loc += 1
	if crafting == []:
		made = false
		return
	for i in range(recipes.size()):
		if recipes[i][0] == crafting or craftingAll == recipes[i][0]:
			crafted = i
			made = true
			return
	made = false
