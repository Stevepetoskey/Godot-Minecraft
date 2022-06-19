extends Sprite

var inventory = [[],[],[]] #Item id, amount, data
var inventoryCraft = [[0,0,0,0],[0,0,0,0]]
var craftingTable = [[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]

var toolMultiplier = {"all":1,"wood":2,"stone":4,"iron":6,"diamond":8,"netherite":9,"gold":12}
var itemData = {11:[2,"wood"],12:[3,"wood"],14:[1,"wood"],17:[4,"wood"],18:[2,"stone"],19:[3,"stone"],20:[1,"stone"],22:[4,"stone"],29:[2,"iron"],30:[3,"iron"],31:[1,"iron"],33:[4,"iron"],36:[2,"diamond"],37:[3,"diamond"],38:[1,"diamond"],40:[4,"diamond"]} #1 shovel 2 pick 3 axe 4 hoe
var foodData = {55:[3,1.8],56:[8,12.8]} #[Food points, saturation]
var itemDamage = {11:2,12:3,14:2,16:4,17:2,18:3,19:4,20:3,21:5,22:4,29:4,30:5,31:4,32:6,33:4,36:5,37:6,38:5,39:7,40:5}
var textures = {1:load("res://textures/Blocks/grass_block.png"),2:load("res://textures/Blocks/dirt.png"),3:load("res://textures/Blocks/stone.png"),4:load("res://textures/Blocks/oak_log.png"),5:load("res://textures/Blocks/oak_leaves.png"),6:load("res://textures/Blocks/coal_ore.png"),7:load("res://textures/Blocks/iron_ore.png"),8:load("res://textures/Blocks/oak_planks.png"),
9:load("res://textures/items/stick.png"),10:load("res://textures/Blocks/crafting_table.png"),11:preload("res://textures/items/wooden_pickaxe.png"),12:preload("res://textures/items/wooden_axe.png"),13:preload("res://textures/Blocks/cobblestone.png"),14:preload("res://textures/items/wooden_shovel.png"),
15:preload("res://textures/items/coal.png"),16:preload("res://textures/items/wooden_sword.png"),17:preload("res://textures/items/wooden_hoe.png"),18:preload("res://textures/items/stone_pickaxe.png"),19:preload("res://textures/items/stone_axe.png"),20:preload("res://textures/items/stone_shovel.png"),21:preload("res://textures/items/stone_sword.png"),
22:preload("res://textures/items/stone_hoe.png"),23:preload("res://textures/Blocks/furnace_front.png"),24:preload("res://textures/items/iron_ingot.png"),25:preload("res://textures/Blocks/coal_block.png"),26:preload("res://textures/Blocks/iron_block.png"),27:preload("res://textures/Blocks/diamond_ore.png"),28:preload("res://textures/Blocks/diamond_block.png"),
29:preload("res://textures/items/iron_pickaxe.png"),30:preload("res://textures/items/iron_axe.png"),31:preload("res://textures/items/iron_shovel.png"),32:preload("res://textures/items/iron_sword.png"),33:preload("res://textures/items/iron_hoe.png"),34:preload("res://textures/items/diamond.png"),35:preload("res://textures/Blocks/bedrock.png"),36:preload("res://textures/items/diamond_pickaxe.png"),
37:preload("res://textures/items/diamond_axe.png"),38:preload("res://textures/items/diamond_shovel.png"),39:preload("res://textures/items/diamond_sword.png"),40:preload("res://textures/items/diamond_hoe.png"),41:preload("res://textures/items/water_bucket.png"),42:preload("res://textures/Blocks/sand.png"),43:preload("res://textures/Blocks/glass.png"),44:preload("res://textures/Blocks/sandstone.png"),45:preload("res://textures/Blocks/snow.png"),46:preload("res://textures/items/snowball.png"),
47:preload("res://textures/items/clay_ball.png"),48:preload("res://textures/Blocks/clay.png"),49:preload("res://textures/items/brick.png"),50:preload("res://textures/Blocks/bricks.png"),51:preload("res://textures/Blocks/smooth_stone.png"),52:preload("res://textures/Blocks/stone_bricks.png"),53:preload("res://textures/Blocks/torch.png"),54:preload("res://textures/Blocks/ladder.png"),55:preload("res://textures/items/porkchop.png"),56:preload("res://textures/items/cooked_porkchop.png"),
57:preload("res://textures/Blocks/oak_sapling.png"),58:preload("res://textures/Blocks/chest/normal_closed.png"),59:preload("res://textures/items/bucket.png"),60:preload("res://textures/items/water_bucket.png"),61:preload("res://textures/items/arrow.png"),62:preload("res://textures/items/oak_door.png"),63:preload("res://textures/items/oak_door.png")}
var items = [9,11,12,14,15,16,17,18,19,20,21,22,24,29,30,31,32,33,34,36,37,38,39,40,46,47,49,55,56,59,61]

func _ready():
	for i in range(9):
		var icon = load("res://assets/inventoryIcon.tscn").instance()
		icon.rect_position = Vector2(i*20-87,-7)
		icon.id = i
		add_child(icon)

func add_to_inventory(id,num):
	var last = 0
	while inventory[0].find(id,last) != -1 and num > 0:
		var loc = inventory[0].find(id,last)
		if inventory[1][loc] + num > 64:
			num -= 64-inventory[1][loc]
			inventory[1][loc] = 64
			last = loc+1
		else:
			inventory[1][loc] += num
			return
	last = 0
	while inventory[0].find(0,last) != -1 and num > 0:
		var loc = inventory[0].find(0,last)
		inventory[0][loc] = id
		if num > 64:
			inventory[1][loc] = 64
			num -= 64
		else:
			inventory[1][loc] = num
			return
		last = loc+1

func remove_from_inventory(loc,num):
	if num >= inventory[1][loc]:
		inventory[0][loc] = 0
		inventory[1][loc] = 0
	else:
		inventory[1][loc] -= num

func can_harvest(block):
	var blockStats = get_node("../..").block_data[block]
	var itemStats = [0,"all"]
	if itemData.has(inventory[0][get_node("select").selected]):
		itemStats = itemData[inventory[0][get_node("select").selected]]
	if (blockStats.minedBy == itemStats[0] and (blockStats.canHarvest.has(itemStats[1]) or blockStats.canHarvest.has("allType"))) or blockStats.canHarvest.has("all"):
		return true

func check_time_to_break(block):
	var blockStats = get_node("../..").block_data[block]
	var itemStats = [0,"all"]
	if itemData.has(inventory[0][get_node("select").selected]):
		itemStats = itemData[inventory[0][get_node("select").selected]]
	var multiplier = 1
	if blockStats.minedBy == itemStats[0]:
		multiplier = toolMultiplier[itemStats[1]]
	var damage = multiplier/ float(blockStats.blockHardness)
	if (blockStats.minedBy == itemStats[0] and (blockStats.canHarvest.has(itemStats[1]) or blockStats.canHarvest.has("allType"))) or blockStats.canHarvest.has("all"):
		damage /= 30
	else:
		damage /= 100
	var ticks = ceil(1/float(damage))
	return ticks/20.0
