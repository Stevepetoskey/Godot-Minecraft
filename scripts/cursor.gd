extends Sprite

var breakLoc = Vector2(0,0)
var breakZ = 1
var stage = -1
var wait = false
var start = false
var z = 1

onready var player = get_node("../Player")
onready var hotbar = get_node("../CanvasLayer/hotbar")
onready var main = get_node("..")

var stick = Vector2(0,0)

const unbreakable = [35,41,60]

func _process(_delta):
	if start:
		if !get_node("../CanvasLayer/Inventory").visible:
			var selectedItem = hotbar.inventory[0][get_node("../CanvasLayer/hotbar/select").selected]
			if abs(get_global_mouse_position().x - player.global_position.x) <= 64:
				position.x = stepify(get_global_mouse_position().x,16)
			else:
				position.x = stepify(player.global_position.x + 64 * sign(get_global_mouse_position().x - player.global_position.x),16)
			if abs(get_global_mouse_position().y - player.global_position.y) <= 64:
				position.y = stepify(get_global_mouse_position().y,16)
			else:
				position.y = stepify(player.global_position.y + 64 * sign(get_global_mouse_position().y - player.global_position.y),16)
			if Input.is_action_just_pressed("ui_end"):
				stick = position
			if Input.is_action_pressed("ui_end"):
				position = stick
			if Input.is_action_just_pressed("toggleLayer"):
				z = abs(z-1)
				z_index = z
				if z < 1:
					$back.visible = true
				else:
					$back.visible = false
			if position != breakLoc or z != breakZ:
				stage = -1
				$breakingEnd.stop()
				$destroy.visible = false
			if Input.is_action_pressed("break") and main.block("get",position/ Vector2(16,16),z) > 0:
				if !$breaking.playing:
					var soundFile = main.sound_data[main.block_data[main.block("get",position/ Vector2(16,16),z)].soundFiles].dig
					$breaking.stream = load("res://Audio/" + soundFile + str(randi()%int(main.sound_amount[soundFile])+1) + ".ogg")
					$breaking.play()
					$breakingEnd.start()
				if !unbreakable.has(main.block("get",position/ Vector2(16,16),z)) and main.block_data[main.block("get",position/ Vector2(16,16),z)].blockHardness != -1 and wait == false:
					breakLoc = position
					breakZ = z
					stage += 1
					if stage < 10:
						$destroy.texture = load("res://textures/Blocks/destroy_stage_" + str(stage) + ".png")
					$destroy.visible = true
					if stage >= 9:
						$breakingEnd.stop()
						var soundFile = main.sound_data[main.block_data[main.block("get",position/ Vector2(16,16),z)].soundFiles].breakBlock
						$breaking.stream = load("res://Audio/" + soundFile + str(randi()%int(main.sound_amount[soundFile])+1) + ".ogg")
						$breaking.play()
						main.build_event("break",position/ Vector2(16,16),0,z)
						get_node("../Player").exhaustion += 0.005
						$destroy.visible = false
					wait = true
					if main.block_data.has(main.block("get",position/ Vector2(16,16),z)):
						$blockSlowdown.start(hotbar.check_time_to_break(main.block("get",position/ Vector2(16,16),z))/10.0)
					else:
						$blockSlowdown.start()
			if Input.is_action_just_pressed("build") and [0,41,60].has(main.block("get",position/ Vector2(16,16),z)):
				if main.block("get",position/ Vector2(16,16),z)==41 and hotbar.inventory[0][get_node("../CanvasLayer/hotbar/select").selected] == 59: #Take water in bucket
					main.build_event("break",position/ Vector2(16,16),0,z)
					hotbar.remove_from_inventory(get_node("../CanvasLayer/hotbar/select").selected,1)
					hotbar.add_to_inventory(41,1)
				if hotbar.foodData.has(selectedItem) and player.hunger < 20: #Eat food
					player.hunger += hotbar.foodData[selectedItem][0]
					var saturation = hotbar.foodData[selectedItem][1]
					if player.hunger < hotbar.foodData[selectedItem][1]:
						saturation = player.hunger
					player.saturation += saturation
					hotbar.remove_from_inventory(get_node("../CanvasLayer/hotbar/select").selected,1)
				elif !hotbar.items.has(selectedItem): #Place block
#					if main.block("get",position/ Vector2(16,16),z) == 41:
#						print(get_node("../water").water)
#						get_node("../water").water.erase(position/ Vector2(16,16))
#						print(get_node("../water").water)
					$breakingEnd.stop()
					var soundFile = main.sound_data[main.block_data[selectedItem].soundFiles].place
					$breaking.stream = load("res://Audio/" + soundFile + str(randi()%int(main.sound_amount[soundFile])+1) + ".ogg")
					$breaking.play()
					main.build_event("build",position/ Vector2(16,16),selectedItem,z)
			elif Input.is_action_just_pressed("build"):
#				if hotbar.itemData.has(hotbar.inventory[0][get_node("../CanvasLayer/hotbar/select").selected]) and hotbar.itemData[hotbar.inventory[0][get_node("../CanvasLayer/hotbar/select").selected]][0] == 4:
				match main.block("get",position/ Vector2(16,16),z):
					10:
						yield(get_tree().create_timer(0.05), "timeout")
						get_node("../CanvasLayer/Inventory").visible = true
						get_node("../CanvasLayer/craftingTable").visible = true
					23:
						yield(get_tree().create_timer(0.05), "timeout")
						get_node("../CanvasLayer/Inventory").visible = true
						get_node("../CanvasLayer/furnace").visible = true
						get_node("../CanvasLayer/Inventory").currentFurnace = main.interactableBlockData[[position/ Vector2(16,16),z]]
					58:
						yield(get_tree().create_timer(0.05),"timeout")
						get_node("../CanvasLayer/chestSmall").visible = true
						get_node("../CanvasLayer/Inventory").visible = true
						get_node("../CanvasLayer/Inventory").currentChest = main.interactableBlockData[[position/ Vector2(16,16),z]]
						get_node("../chunks").get_node(str(main.get_chunk(position.x/16))).get_node(str(z) + "," + str(main.chunkifyI(position.x/16)) + "," + str(position.y/16)).interact(true)

func get_chunk(xPos):
	return int(stepify(xPos,main.chunkSize.x)/main.chunkSize.x)

func _on_blockSlowdown_timeout():
	wait = false

func _on_Node2D_start():
	start = true

func _on_breakingEnd_timeout():
	$breaking.stop()
