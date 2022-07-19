extends Sprite

var toolMultiplier = {"all":1,"wood":2,"stone":4,"iron":6,"diamond":8,"netherite":9,"gold":12}
var itemData = {11:[2,"wood"],12:[3,"wood"],14:[1,"wood"],16:[5,"wood"],17:[4,"wood"],18:[2,"stone"],19:[3,"stone"],20:[1,"stone"],21:[5,"stone"],22:[4,"stone"],29:[2,"iron"],30:[3,"iron"],31:[1,"iron"],32:[5,"iron"],33:[4,"iron"],36:[2,"diamond"],37:[3,"diamond"],38:[1,"diamond"],39:[5,"diamond"],40:[4,"diamond"],
85:[2,"gold"],86:[3,"gold"],87:[1,"gold"],88:[5,"gold"],89:[4,"gold"]} #1 shovel 2 pick 3 axe 4 hoe 5 sword
var foodData = {55:[3,1.8],56:[8,12.8],81:[4,2.4],90:[4,0.8],93:[5,6]} #[Food points, saturation]
var itemDamage = {11:2,12:3,14:2,16:4,17:2,18:3,19:4,20:3,21:5,22:4,29:4,30:5,31:4,32:6,33:4,36:5,37:6,38:5,39:7,40:5,85:3,86:4,87:2,88:5,89:3}
var textures = {1:load("res://textures/Blocks/grass_block.png"),2:load("res://textures/Blocks/dirt.png"),3:load("res://textures/Blocks/stone.png"),4:load("res://textures/Blocks/oak_log.png"),5:load("res://textures/Blocks/oak_leaves.png"),6:load("res://textures/Blocks/coal_ore.png"),7:load("res://textures/Blocks/iron_ore.png"),8:load("res://textures/Blocks/oak_planks.png"),
9:load("res://textures/items/stick.png"),10:load("res://textures/Blocks/crafting_table.png"),11:preload("res://textures/items/wooden_pickaxe.png"),12:preload("res://textures/items/wooden_axe.png"),13:preload("res://textures/Blocks/cobblestone.png"),14:preload("res://textures/items/wooden_shovel.png"),
15:preload("res://textures/items/coal.png"),16:preload("res://textures/items/wooden_sword.png"),17:preload("res://textures/items/wooden_hoe.png"),18:preload("res://textures/items/stone_pickaxe.png"),19:preload("res://textures/items/stone_axe.png"),20:preload("res://textures/items/stone_shovel.png"),21:preload("res://textures/items/stone_sword.png"),
22:preload("res://textures/items/stone_hoe.png"),23:preload("res://textures/Blocks/furnace_front.png"),24:preload("res://textures/items/iron_ingot.png"),25:preload("res://textures/Blocks/coal_block.png"),26:preload("res://textures/Blocks/iron_block.png"),27:preload("res://textures/Blocks/diamond_ore.png"),28:preload("res://textures/Blocks/diamond_block.png"),
29:preload("res://textures/items/iron_pickaxe.png"),30:preload("res://textures/items/iron_axe.png"),31:preload("res://textures/items/iron_shovel.png"),32:preload("res://textures/items/iron_sword.png"),33:preload("res://textures/items/iron_hoe.png"),34:preload("res://textures/items/diamond.png"),35:preload("res://textures/Blocks/bedrock.png"),36:preload("res://textures/items/diamond_pickaxe.png"),
37:preload("res://textures/items/diamond_axe.png"),38:preload("res://textures/items/diamond_shovel.png"),39:preload("res://textures/items/diamond_sword.png"),40:preload("res://textures/items/diamond_hoe.png"),41:preload("res://textures/items/water_bucket.png"),42:preload("res://textures/Blocks/sand.png"),43:preload("res://textures/Blocks/glass.png"),44:preload("res://textures/Blocks/sandstone.png"),45:preload("res://textures/Blocks/snow.png"),46:preload("res://textures/items/snowball.png"),
47:preload("res://textures/items/clay_ball.png"),48:preload("res://textures/Blocks/clay.png"),49:preload("res://textures/items/brick.png"),50:preload("res://textures/Blocks/bricks.png"),51:preload("res://textures/Blocks/smooth_stone.png"),52:preload("res://textures/Blocks/stone_bricks.png"),53:preload("res://textures/Blocks/torch.png"),54:preload("res://textures/Blocks/ladder.png"),55:preload("res://textures/items/porkchop.png"),56:preload("res://textures/items/cooked_porkchop.png"),
57:preload("res://textures/Blocks/oak_sapling.png"),58:preload("res://textures/Blocks/chest/normal_closed.png"),59:preload("res://textures/items/bucket.png"),60:preload("res://textures/items/water_bucket.png"),61:preload("res://textures/items/arrow.png"),62:preload("res://textures/items/oak_door.png"),63:preload("res://textures/items/oak_door.png"),64:preload("res://textures/Blocks/birch_log.png"),65:preload("res://textures/Blocks/birch_planks.png"),66:preload("res://textures/Blocks/birch_leaves.png"),67:preload("res://textures/Blocks/birch_sapling.png"),
68:preload("res://textures/Blocks/spruce_log.png"),69:preload("res://textures/Blocks/spruce_planks.png"),70:preload("res://textures/Blocks/spruce_leaves.png"),71:preload("res://textures/Blocks/spruce_sapling.png"),72:preload("res://textures/Blocks/gold_ore.png"),73:preload("res://textures/Blocks/gold_block.png"),74:preload("res://textures/items/charcoal.png"),75:preload("res://textures/items/gold_ingot.png"),76:preload("res://textures/items/gold_nugget.png"),77:preload("res://textures/Blocks/lapis_ore.png"),78:preload("res://textures/items/lapis_lazuli.png"),
79:preload("res://textures/Blocks/lapis_block.png"),80:preload("res://textures/Blocks/redstone_torch.png"),81:preload("res://textures/items/apple.png"),82:preload("res://textures/Blocks/redstone_ore.png"),83:preload("res://textures/items/redstone.png"),84:preload("res://textures/Blocks/redstone_block.png"),85:preload("res://textures/items/golden_pickaxe.png"),86:preload("res://textures/items/golden_axe.png"),87:preload("res://textures/items/golden_shovel.png"),88:preload("res://textures/items/golden_sword.png"),89:preload("res://textures/items/golden_hoe.png"),
90:preload("res://textures/items/rotten_flesh.png"),91:preload("res://textures/items/wheat_seeds.png"),92:preload("res://textures/items/wheat.png"),93:preload("res://textures/items/bread.png"),94:preload("res://textures/Blocks/grass.png"),95:preload("res://textures/Blocks/farmland.png"),96:preload("res://textures/Blocks/farmland_moist.png"),97:preload("res://textures/Blocks/stairs/stone_brick_stairs0.png"),98:preload("res://textures/Blocks/stairs/cobblestone_stairs0.png"),
99:preload("res://textures/Blocks/stairs/oak_stairs0.png"),100:preload("res://textures/Blocks/stairs/birch_stairs0.png"),101:preload("res://textures/Blocks/stairs/spruce_stairs0.png"),102:preload("res://textures/Blocks/stairs/sandstone_stairs0.png"),103:preload("res://textures/Blocks/stairs/brick_stairs0.png")}
var items = [9,11,12,14,15,16,17,18,19,20,21,22,24,29,30,31,32,33,34,36,37,38,39,40,46,47,49,55,56,59,61,75,78,81,85,86,87,88,89,90,91,92,93]
var stairs = [97,98,99,100,101,102,103]

onready var inventory = get_node("../Inventory")

func _ready():
	for i in range(9):
		var icon = load("res://assets/hotbarIcon.tscn").instance()
		icon.loc = i
		icon.rect_position = Vector2(i*20-88,-7)
		add_child(icon)

func add_to_inventory(id,num) -> void:
	var last = 0
	while find_id(inventory.inventory,id,last) != -1 and num > 0:
		var loc = find_id(inventory.inventory,id,last)
		if inventory.inventory[loc]["amount"] + num > 64:
			num -= 64-inventory.inventory[loc]["amount"]
			inventory.inventory[loc]["amount"] = 64
			last = loc+1
		else:
			inventory.inventory[loc]["amount"] += num
			return
	last = 0
	while find_id(inventory.inventory,0,last) != -1 and num > 0:
		var loc = find_id(inventory.inventory,0,last)
		inventory.inventory[loc]["id"] = id
		if num > 64:
			inventory.inventory[loc]["amount"] = 64
			num -= 64
		else:
			inventory.inventory[loc]["amount"] = num
			return
		last = loc+1

func find_id(array,id,from = 0) -> int:
	for itemId in range(from,array.size()):
		if array[itemId]["id"] == id:
			return itemId
	return -1

func remove_from_inventory(loc,num):
	if num >= inventory.inventory[loc]["amount"]:
		inventory.inventory[loc]["id"] = 0
		inventory.inventory[loc]["amount"] = 0
	else:
		inventory.inventory[loc]["amount"] -= num

func can_harvest(block):
	var blockStats = get_node("../..").block_data[block]
	var itemStats = [0,"all"]
	if itemData.has(inventory.inventory[get_node("select").selected]["id"]):
		itemStats = itemData[inventory.inventory[get_node("select").selected]["id"]]
	if (blockStats.minedBy == itemStats[0] and (blockStats.canHarvest.has(itemStats[1]) or blockStats.canHarvest.has("allType"))) or blockStats.canHarvest.has("all"):
		return true

func check_time_to_break(block):
	var blockStats = get_node("../..").block_data[block]
	var itemStats = [0,"all"]
	if itemData.has(inventory.inventory[get_node("select").selected]["id"]):
		itemStats = itemData[inventory.inventory[get_node("select").selected]["id"]]
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
