extends StaticBody2D

var id = 0
var z = 0

var lightSource = false
var lightEmit = 0

var shadeRotations = [90,180,0,270] #[left,top,bottom,right]

var data = {}
var containsData = false
var smeltable = {}
var fuel = {}
var smelting = false
var rendered = false
var isSmelting = 0

#Door vars
var open = true
var secondPart : Object

onready var main = get_node("../../..")

# Called when the node enters the scene tree for the first time.
func _ready():
	render()

func render():
	if containsData:
		data = main.interactableBlockData[[global_position/ Vector2(16,16),z]]
	if [62,63].has(id):
		$CollisionShape2D.shape.extents = Vector2(3,8)
		$CollisionShape2D.position.x = -6.5
		open = data
		open_door(false)
	main.connect("update",self,"on_update")
	z_index = 1
	if z < 1:
		z_index = -1
	$Sprite.material.set_shader_param("layerShade",1.0)
	if z == 0:
		$Sprite.material.set_shader_param("layerShade",0.75)
		$CollisionShape2D.disabled = true
	$Sprite.texture = load("res://textures/Blocks/" + main.block_data[id].texture + ".png")
	match id:
		5:
			$Sprite.material.set_shader_param("color",Color(0.25,0.56,0.11,1.0))
		23:
			get_node("../../../CanvasLayer/Inventory").connect("updateFurnace",self,"update_Furnace")
			smeltable = get_node("../../../CanvasLayer/furnace").smeltable
			fuel = get_node("../../../CanvasLayer/furnace").fuel
			update_Furnace()
		41,53:
			$CollisionShape2D.disabled = true
		54,67,71:
			$CollisionShape2D.disabled = true
			$BlockCollide/CollisionShape2D.disabled = false
		57:
			$CollisionShape2D.disabled = true
			$Sapling.start()
		66:
			$Sprite.material.set_shader_param("color",Color(0.36,0.83,0.16,1.0))
		70:
			$Sprite.material.set_shader_param("color",Color(0.12,0.36,0.17,1.0))
		94:
			$CollisionShape2D.disabled = true
			$Sprite.material.set_shader_param("color",Color(0.25,0.56,0.11,1.0))
	rendered = true

func update_Furnace():
	if !smelting:
#		print(main.interactableBlockData)
#		print(global_position/ Vector2(16,16))
#		print(data)
#		print(id)
		if data[2] != 0 and smeltable.has(data[0][0]):
			$FurnaceFuel.start()
			$FurnaceTop.start(10/22.0)
			smelting = true
		else:
			if smeltable.has(data[0][0]) and fuel.has(data[0][1]) and (smeltable[data[0][0]] == data[0][2] or data[0][2] == 0):
				data[3] = fuel[data[0][1]]
				remove_item(1)
			if data[3] > 0:
				$FurnaceFuel.start()
				$FurnaceTop.start(10/22.0)
				smelting = true
	elif data[0][0] != isSmelting:
		if smeltable.has(data[0][0]) and (smeltable[data[0][0]] == data[0][2] or data[0][2] == 0):
			data[2] = 0
			$FurnaceTop.start(10/22.0)
	isSmelting = data[0][0]
	$Sprite.texture = [load("res://textures/Blocks/furnace_front.png"),load("res://textures/Blocks/furnace_front_on.png")][int(smelting)]

func on_update():
	if z < 1:
		var i = 0
		for x in range(-1,2):
			for y in range(-1,2):
				if abs(x) != abs(y):
					var block = get_node("../../..").block("get",global_position/ Vector2(16,16) + Vector2(x,y))
					if block != null and block > 0 and ![53,54,62,63].has(block) and !has_node(str(x) + str(y)):
						var sprite = Sprite.new()
						sprite.texture = load("res://textures/Blocks/BackgroundShade.png")
						sprite.rotation_degrees = shadeRotations[i]
						sprite.name = str(x)+str(y)
						add_child(sprite)
					if block == 0 and has_node(str(x) + str(y)):
						get_node(str(x) + str(y)).queue_free()
					i+=1
	if id != 0 and main.block("get",global_position/ Vector2(16,16),z) != id:
		queue_free()

func remove_item(loc):
	data[1][loc] -= 1
	if data[1][loc] <= 0:
		data[0][loc] = 0

func _on_FurnaceFuel_timeout():
	data[3] -= 1
	if data[3] <= 0:
		if fuel.has(data[0][1]) and smeltable.has(data[0][0]):
			data[3] = fuel[data[0][1]]
			remove_item(1)
			$FurnaceFuel.start()
		else:
			smelting = false
	else:
		$FurnaceFuel.start()

func _on_FurnaceTop_timeout():
	if smelting and data[0][0] > 0 and (smeltable[data[0][0]] == data[0][2] or data[0][2] == 0):
		data[2] += 1
		if data[2] >= 22: #When item has finished smelting
			data[0][2] = smeltable[data[0][0]]
			data[1][2] += 1
			remove_item(0)
			data[2] = 0
		$FurnaceTop.start(10/22.0)
	elif data[2] > 0:
		data[2] -= 2
		$FurnaceTop.start(10/22.0)
	else:
		data[2] = 0

func _on_Sapling_timeout():
	data[0] += 1
	if data[0] >= data[1]:
		var pos = Vector2(round(global_position.x/16),round(global_position.y/16)+1)
		var treeH = int(rand_range(4,6))
		var logType = "4"
		var treeType = "normal"
		match id:
			67:
				logType = "64"
				treeType = "birch"
				treeH = int(rand_range(4,10))
			71:
				logType = "68"
				treeType = "spruce"
				if randi()%2 == 1:
					treeType = "spruce2"
				treeH = int(rand_range(4,10))
		var canGrow = true
		for h in range(2,treeH):
			if main.block("get",Vector2(pos.x,pos.y-h),z) != 0:
				canGrow = false
		if canGrow:
			for h in range(1,treeH):
				main.block(logType,Vector2(pos.x,pos.y-h),z)
			treeH = pos.y-treeH
			for tX in range(5):
				for tY in range(main.trees[treeType][tX].size(),-1,-1):
					if main.trees[treeType][tX][tY] > 1 and main.block("get",Vector2(pos.x+(tX-2),tY+treeH),z) == 0:
						main.block(str(main.trees[treeType][tX][tY]),Vector2(pos.x+(tX-2),tY+treeH),z)
					if z != 1 and main.trees[treeType][tX][tY] > 1 and main.block("get",Vector2(pos.x+(tX-2),tY+treeH),1) == 0:
						main.block(main.trees[treeType][tX][tY],Vector2(pos.x+(tX-2),tY+treeH),1)
			$Sapling.stop()
			for i in range(-1,2):
				main.load_chunk(main.get_chunk(pos.x)+i)
			id = 4
			render()
		else:
			data[0] = 0

func interact(opened):
	if !opened:
		yield(get_tree().create_timer(0.5),"timeout")
		$Sprite.texture = load("res://textures/Blocks/chest/normal_closed.png")
	else:
		$Sprite.texture = load("res://textures/Blocks/chest/normal_opened.png")

func open_door(change = true):
	if change:
		open = !open
	if open:
		match id:
			62:
				$Sprite.texture = load("res://textures/Blocks/oak_door_bottom.png")
			63:
				$Sprite.texture = load("res://textures/Blocks/oak_door_top.png")
		$Sprite.visible = true
		$CollisionShape2D.disabled = true
	else:
		$Sprite.visible = false
		$Door.visible = true
		$Door.texture = load("res://textures/Blocks/oak_door_bottom_closed.png")
		$CollisionShape2D.disabled = false
	main.interactableBlockData[[global_position/ Vector2(16,16),z]] = open
