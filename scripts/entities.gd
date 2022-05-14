extends Node2D

const EntitySimulationRect = Vector2(44,34)
#make it so it reads and saves on a dictionary
var entities = [] #[Type,position]
var entityAssets = {"player":preload("res://assets/Player.tscn"),"pig":preload("res://assets/Pig.tscn"),"item":preload("res://assets/Item.tscn"),"zombie":preload("res://assets/Zombie.tscn"),"skeleton":preload("res://assets/Skeleton.tscn"),"arrow":preload("res://assets/Arrow.tscn")}
var entityType = {"player":"~","pig":"p","item":"~","zombie":"h","skeleton":"h","arrow":"~"} #p: passive, n: nuetral, h: hostile, ~: none
var saved = false

onready var main = get_node("..")
onready var inventory = get_node("../CanvasLayer/hotbar")

signal loaded

func round_vec2( vec2 : Vector2): return Vector2(round(vec2.x),round(vec2.y))

func _process(delta):
	get_node("../CanvasLayer/EC").text = "EC: " + str(get_child_count()+1)

func fill_entities():
	var pCount = 0
	var hCount = 0
	for entity in get_children():
		if main.get_chunk(round(entity.position.x/16)) < get_node("../Player").playerChunk+5 and main.get_chunk(round(entity.position.x/16)) >= get_node("../Player").playerChunk-5:
			match entityType[entity.TYPE]:
				"p":
					pCount+=1
				"n","h":
					hCount += 1
	for chunkX in range(get_node("../Player").playerChunk-5,get_node("../Player").playerChunk+5):
		for x in range(0,main.chunkSize.x):
			for y in range(0,main.chunkSize.y):
				var pos = Vector2(x+(chunkX*main.chunkSize.x),y)
				var amLvl = get_node("../Lighting").ambientLevel
				if pCount < 10:
					if randi()%10 == 1 and amLvl >= 9 and main.block("get",pos) == 0 and main.block("get",pos,0) == 0 and main.block("get",pos + Vector2(0,1)) ==1:
						var pig = entityAssets["pig"].instance()
						pig.position = pos*Vector2(16,16)
						add_child(pig)
						pCount += 3
#				if hCount < 20:
#					if randi()%10 == 1 and get_node("../Lighting").get_light_level(Vector2(x,y)) <= 7 and main.block("get",pos) == 0 and main.block("get",pos-Vector2(0,1)) == 0 and !get_node("../Lighting").transparent.has(main.block("get",pos + Vector2(0,1))):
#						var zombie = entityAssets["zombie"].instance()
#						zombie.position = pos*Vector2(16,16)
#						add_child(zombie)
#						hCount += 3

func spawn_in_chunk(chunkX):
	if !main.chunks[chunkX][2]:
		for x in range(0,main.chunkSize.x):
			for y in range(0,main.chunkSize.y):
				var pos = Vector2(x+(chunkX*main.chunkSize.x),y)
				var amLvl = get_node("../Lighting").ambientLevel
				if randi()%10 == 1 and amLvl >= 9 and main.block("get",pos) == 0 and main.block("get",pos,0) == 0 and main.block("get",pos + Vector2(0,1)) ==1:
					var pig = entityAssets["pig"].instance()
					pig.position = pos*Vector2(16,16)
					add_child(pig)
				if randi()%10 == 1 and amLvl <= 7 and main.block("get",pos) == 0 and main.block("get",pos-Vector2(0,1)) == 0 and !get_node("../Lighting").transparent.has(main.block("get",pos + Vector2(0,1))):
					var zombie = entityAssets["zombie"].instance()
					zombie.position = pos*Vector2(16,16)
					add_child(zombie)
				if randi()%10 == 1 and amLvl <= 7 and main.block("get",pos) == 0 and main.block("get",pos-Vector2(0,1)) == 0 and !get_node("../Lighting").transparent.has(main.block("get",pos + Vector2(0,1))):
					var skeleton = entityAssets["skeleton"].instance()
					skeleton.position = pos*Vector2(16,16)
					add_child(skeleton)
		main.chunks[chunkX][2] = true

func remove_in_chunk(chunkX):
	for child in get_children():
		if child.name != "Spawn" and main.get_chunk(child.position.x) == chunkX:
			child.queue_free()

func add_item(id,num,pos,dropped):
	if id > 0:
		var item = load("res://assets/Item.tscn").instance()
		item.motion.x = 64*int(dropped)
		if dropped:
			item.collectable = false
		item.itemID = id
		item.get_node("Sprite").texture = get_node("../CanvasLayer/hotbar").textures[id]
		item.itemNum = num
		item.position = pos
		add_child(item)

func save():
	entities = []
	for child in get_children():
		if child.name != "Spawn":
			var type = child.TYPE
			match type:
				"player":
					entities.append([type,child.position,child.health,child.hunger,child.motion,child.inAir,child.firstHeight,child.new])
				"pig":
					entities.append([type,child.position,child.health])
				"item":
					entities.append([type,child.position,child.itemID,child.itemNum])
				"zombie":
					entities.append([type,child.position,child.health])
				"skeleton":
					entities.append([type,child.position,child.health])
				"arrow":
					entities.append([type,child.position,child.motion,child.dmg])
				_:
					entities.append([type,child.position])
	emit_signal("loaded")
	saved = true

func load_data():
	for i in range(entities.size()):
		var type = entities[i][0]
		var data = entities[i]
		var entity = entityAssets[type.to_lower()].instance()
		match type:
			"player":
				entity.position = data[1]; entity.health = data[2]; entity.hunger = data[3]; entity.motion = data[4]; entity.inAir = data[5]; entity.firstHeight = data[6]; entity.new = data[7]
			"pig":
				entity.position = data[1]; entity.health = data[2]
			"item":
				entity.position = data[1]; entity.itemID = data[2]; entity.itemNum = data[3]
			"zombie":
				entity.position = data[1]; entity.health = data[2]
			"skeleton":
				entity.position = data[1]; entity.health = data[2]
			"arrow":
				entity.position = data[1]; entity.motion = data[2]; entity.dmg = data[3]
			_:
				entity.position = data[1]
		add_child(entity)

func get_damage():
	if inventory.itemDamage.has(inventory.inventory[0][get_node("../CanvasLayer/hotbar/select").selected]):
		return inventory.itemDamage[inventory.inventory[0][get_node("../CanvasLayer/hotbar/select").selected]]
	else:
		return 1

func _on_Entity_timeout():
	fill_entities()
	get_node("../Entity").start(rand_range(10,120))

func _on_Node2D_world_loaded():
	load_data()
	get_node("../Entity").start(rand_range(10,120))
