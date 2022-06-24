extends Node2D

const chunkSize = Vector2(16,128)
const WATERLEVEL = 75
const LOADRECT = Vector2(16,11) #Normal (14,9)
const BLOCK = preload("res://assets/block.tscn")
const BLOCKSHADER = preload("res://shaders/block.tres")
const WATERSHADER = preload("res://shaders/Water.tres")
const WATER = preload("res://assets/Water.tscn")
const INTERACTABLE_BLOCK = [23,57,62,63,67]
const BIOME_TYPES = {
	"Plains":{"id":0,"layers":[[1,[1,1]],[2,[2,3]]],"trees":["normal","birch"]},
	"Forest":{"id":1,"layers":[[1,[1,1]],[2,[2,3]]],"trees":["normal","birch"]},
	"Desert":{"id":2,"layers":[[42,[1,3]],[44,[2,3]]],"trees":[]},
	"Frozen Desert":{"id":3,"layers":[[45,[1,1]],[2,[2,3]]],"trees":[]},
	"Tundra":{"id":4,"layers":[[45,[1,1]],[2,[2,3]]],"trees":["spruce","spruce2"]},
	"Frozen Forest":{"id":5,"layers":[[2,[3,4]]],"trees":["spruce","spruce2"]},
	}

var chestData = [[],[]]
var newData = {"Entity":[],"Player":[Vector2(0,0),20,600,Vector2(0,0),false,0,true]}

var chunks = {} #ChunkX: [Foreground,background,modified,already Spawned]
var toPlace = {} #ChunkX: [[block id, loc]]
var interactableBlockData = {}
var renderThread = Thread.new()
var updating = false
export var noise : OpenSimplexNoise
export var temps : OpenSimplexNoise
export var precip : OpenSimplexNoise
export var cave : OpenSimplexNoise
var path = "user://saves/"
var dataPath = "res://data/"
var worldName = "newWorld"
var chunksLoaded = 0
onready var globals = get_node("/root/GlobalScript")
onready var transparent = $Lighting.transparent
onready var player = $Player

signal update
signal start
signal world_loaded

var worldSeed = 0
var worldType = "Default"
var trees = {"normal": [[0,0,5],[0,5,5],[5,5,5],[0,0,5],[0,0,0]],"birch": [[0,0,66],[0,66,66],[66,66,66],[0,0,66],[0,0,0]],"spruce": [[0,0,0],[0,70,70],[70,70,70],[0,70,70],[0,0,0]],"spruce2": [[0,0,70,0,70],[0,70,70,70,70],[70,70,70,70,70],[0,70,70,70,70],[0,0,70,0,70]]} #[x[y]]
var block_data = {}
var sound_data = {}
var sound_amount = {}
var lightData = []
var time

var breakLoc = Vector2(0,0)
var breakp = 0

class sound:
	var step :String
	var dig : String
	var breakBlock : String
	var fall : String
	var place : String
	
	func _init(s,d,b,f,p):
		step = s; dig = d; breakBlock = b; fall = f; place = p

class block:
	
	var blockName : String
	var blockId : int
	var minedBy : int #0:none,1:shovel,2:pick,3:axe
	var blockHardness : float
	var canHarvest : Array
	var drops : Array
	var lightSource : bool
	var lightEmit : int
	var texture : String
	var soundFiles : String
	
	func _init(Name,id,mined,hardness,harvestBy,drop,tex,sound,canLight = false,lightE = 0) -> void:
		blockName = Name; blockId = id; minedBy = mined; blockHardness = hardness; canHarvest = harvestBy; drops = drop; lightSource = canLight; lightEmit = lightE; texture = tex; soundFiles = sound

func get_json(file : String):
	var data_file = File.new()
	var doesExist = File.new()
	if data_file.open(dataPath + file, File.READ) != OK:
		print("Json error: getting json file " + file)
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		print("Json error: cannot parse json file " + file )
		return
	return data_parse.result

# Called when the node enters the scene tree for the first time.
func _ready():
	#Loads block data
	var json_block_data = get_json("block_data.json")
	for blockData in json_block_data:
		var data = json_block_data[blockData]
		if !data.has("light_source"):
			block_data[int(blockData)] = block.new(data["name"],int(data["id"]),int(data["mined_by"]),data["block_hardness"],data["can_harvest"],data["drops"],data["texture"],data["sound_file_name"])
		else:
			block_data[int(blockData)] = block.new(data["name"],int(data["id"]),int(data["mined_by"]),data["block_hardness"],data["can_harvest"],data["drops"],data["texture"],data["sound_file_name"],data["light_source"],data["light_value"])
	#Loads sound data
	var json_sound_data = get_json("sound.json")
	for soundi in json_sound_data:
		var data = json_sound_data[soundi]
		sound_data[soundi] = sound.new(data["step"],data["dig"],data["break"],data["fall"],data["place"])
	#Loads number of audio files per sound
	sound_amount = get_json("sound_num.json")
	
	get_node("CanvasLayer/Loading").visible = true
	worldName = globals.worldNamePath
	if !globals.new: #Checks if save directory exists, if not, creates a new one
		print("loaded")
		var data = globals.read_savegame()
		chunks = data["World"]
		$CanvasLayer/hotbar.inventory = data["Inventory"]
		interactableBlockData = data["InteractBlocks"]
		if data.has("Entity"):
			$entities.entities = data["Entity"].duplicate(true)
		else:
			$entities.entities = newData["Entity"]
		var playerData = newData["Player"]
		if data.has("Player"):
			playerData = data["Player"]
		if data.has("Seed"):
			worldSeed = data["Seed"]
		else:
			worldSeed = globals.worldSeed
		if data.has("World_Type"):
			worldType = data["World_Type"]
		if data.has("Gamemode"):
			globals.gamemode = data["Gamemode"]
		if playerData[2] > 20:
			playerData[2] = 20
		if playerData.size() < 8:
			playerData.append(0)
			playerData.append(0)
		player.position = playerData[0]; player.health = playerData[1]; player.hunger = playerData[2]; player.motion = playerData[3]; player.inAir = playerData[4]; player.firstHeight = playerData[5]; player.new = playerData[6]; player.saturation = playerData[7]; player.exhaustion = playerData[8]
	else:
		for _i in range(36):
			$CanvasLayer/hotbar.inventory[0].append(0)
			$CanvasLayer/hotbar.inventory[1].append(0)
			$CanvasLayer/hotbar.inventory[2].append([])
		worldSeed = globals.worldSeed
		worldType = globals.worldType
		$entities.entities = newData["Entity"]
	for _i in range(27):
		chestData[0].append(0)
		chestData[1].append(0)
	seed(worldSeed)
	cave.seed = worldSeed
	noise.seed = randi()
	temps.seed = randi()
	precip.seed = randi()
	update_chunks(player.playerChunk)
	if globals.new:
		save_game()
	emit_signal("start")

# --- save/load ---
func save_game():
	get_node("entities").save()
#	yield(get_node("entities"),"loaded")
	var data = {}
	data["Seed"] = worldSeed
	data["World"] = chunks
	data["Inventory"] = $CanvasLayer/hotbar.inventory
	data["Seed"] = worldSeed
	data["InteractBlocks"] = interactableBlockData
	if !get_node("entities").saved:
		yield(get_node("entities"),"loaded")
	get_node("entities").saved = false
	data["Entity"] = $entities.entities
	data["Name"] = worldName
	data["Player"] = [player.position,player.health,player.hunger,player.motion,player.inAir,player.firstHeight,player.new,player.saturation,player.exhaustion]
	data["World_Type"] = worldType
	data["Gamemode"] = globals.gamemode
	globals.save(data)

# ---Chunk gernaration---
func update_chunks(playerChunk):
	var chunksLoad = []
	for i in range(playerChunk-2,playerChunk+3):
		chunksLoad.append(str(i))
		if !$chunks.has_node(str(i)):
			create_chunk(i)
			get_node("entities").spawn_in_chunk(i)
	for chunk in $chunks.get_children():
		if !chunksLoad.has(chunk.name):
			unload_chunk(int(chunk.name))
	if chunks.has(playerChunk-10):
		chunks[playerChunk-10][2] = false
		$entities.remove_in_chunk(playerChunk-5)
	if chunks.has(playerChunk+10):
		chunks[playerChunk+10][2] = false
		$entities.remove_in_chunk(playerChunk+5)

func unload_chunk(chunkX):
	$chunks.get_node(str(chunkX)).queue_free()

#--Generating world into chunk--
func create_chunk(chunkX):
	var generate = !chunks.has(chunkX)
	var chunkObj = Node2D.new()
	chunkObj.name = str(chunkX)
	chunkObj.position.x = chunkX*(chunkSize.x*16)
	$chunks.add_child(chunkObj)
	if generate:
		chunks[chunkX] = [[],[],false,false]
		var chunk = chunks[chunkX][1]
		for x in range(chunkSize.x):
			chunk.append([])
			for _y in range(chunkSize.y):
				chunk[x].append(0)
		match worldType:
			"Default":
				var lastTree = -1
				for x in range(chunkSize.x):
					var height = round(((noise.get_noise_1d(x+(chunkX*chunkSize.x))+1)/4.0)*chunkSize.y)+40
					var biome = get_biome(x+(chunkX*chunkSize.x))
					var heights = [height+int(rand_range(biome["layers"][0][1][0],biome["layers"][0][1][1]+1))]
					for i in range(1,biome["layers"].size()):
						heights.append(heights[i-1]+int(rand_range(biome["layers"][i][1][0],biome["layers"][i][1][1]+1)))
					for y in range(chunkSize.y):
						if y < height and y > WATERLEVEL:
							chunk[x][y] = 41
						if y >= height:
							var block = -1
							for y2 in range(heights.size()):
								if y < heights[y2]:
									block = biome["layers"][y2][0]
									break
							if block == -1:
								chunk[x][y] = 3
							else:
								chunk[x][y] = block
							if y == height and y < WATERLEVEL:
								if (x-lastTree > 1 or lastTree == -1) and randi()%2 == 1 and cave.get_noise_3d(x+(chunkX*chunkSize.x),y,0) < 0.21 and [1,5].has(biome["id"]):
									lastTree = x
									var treeH = int(rand_range(4,6))
									var treeType = "normal"
									var logType = 4
									if biome["id"] == 1 and randi()%4 == 1:
										treeType = "birch"
										logType = 64
										treeH = int(rand_range(4,10))
									elif biome["id"] == 5:
										treeType = "spruce"
										if randi() % 2 == 1:
											treeType = "spruce2"
										logType = 68
										treeH = int(rand_range(6,10))
									for h in range(1,treeH):
										block(str(logType),Vector2(chunkX*chunkSize.x+x,y-h),0)
									treeH = y-treeH
									for tX in range(5):
										for tY in range(trees[treeType][tX].size()-1,-1,-1):
											if trees[treeType][tX][tY] > 1 and block("get",Vector2(chunkX*chunkSize.x+x+(tX-2),tY+treeH)) == 0:
												block(str(trees[treeType][tX][tY]),Vector2(chunkX*chunkSize.x+x+(tX-2),tY+treeH))
				#yield(get_tree().create_timer(0.01), "timeout")
				for x in range(chunkSize.x):
					var height = round(((noise.get_noise_1d(x+(chunkX*chunkSize.x))+1)/4.0)*chunkSize.y)+40
					for y in range(chunkSize.y):
						if y > WATERLEVEL+3 and y > height and y <= height + 3 and randi()%5 == 1:
							for x2 in range(x-5,x+5):
								for y2 in range(y-5,y+5):
									if randi() % (int(abs(x2-x)+abs(y2-y))+1) <= 1.5:
										if [3].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
											block("44",Vector2(chunkX*chunkSize.x+x2,y2),1)
										elif [1,2,45].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
											block("42",Vector2(chunkX*chunkSize.x+x2,y2))
						if y > WATERLEVEL+3 and y > height and y <= height + 3 and randi()%30 == 1:
							for x2 in range(x-5,x+5):
								for y2 in range(y-5,y+5):
									if randi() % (int(abs(x2-x)+abs(y2-y))+1) <= 1.5 and [1,2,45,42].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
#										if [1,2].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
										block("48",Vector2(chunkX*chunkSize.x+x2,y2),1)
						if y > 62 and randi()%100 == 1:
							for x2 in range(x-3,x+3):
								for y2 in range(y-1,y+2):
									if randi()%2 == 1 and block("get",Vector2(chunkX*chunkSize.x+x2,y2)) == 3:
										block("6",Vector2(chunkX*chunkSize.x+x2,y2))
						elif y > 80 and randi()%150 == 1:
							for x2 in range(x-1,x+2):
								for y2 in range(y-1,y+2):
									if randi()%2 == 1 and block("get",Vector2(chunkX*chunkSize.x+x2,y2)) == 3:
										block("7",Vector2(chunkX*chunkSize.x+x2,y2))
						elif y > 120 and randi()%100 == 1:
							for x2 in range(x-1,x+2):
								for y2 in range(y-1,y+2):
									if randi()%2 == 1 and block("get",Vector2(chunkX*chunkSize.x+x2,y2)) == 3:
										block("27",Vector2(chunkX*chunkSize.x+x2,y2))
						if y == chunkSize.y-1:
							chunk[x][y] = 35
			"Flat":
				for x in range(chunkSize.x):
					for y in range(chunkSize.y):
						if y == chunkSize.y-1:
							chunk[x][y] = 35
						elif y >= chunkSize.y-3:
							chunk[x][y] = 2
						elif y == chunkSize.y-4:
							chunk[x][y] = 1
		chunks[chunkX][0] = chunks[chunkX][1].duplicate(true)
		for x in range(chunkSize.x):
			for y in range(chunkSize.y):
				if cave.get_noise_3d(x+(chunkX*chunkSize.x),y,0) > 0.21 and chunks[chunkX][1][x][y] != 35 and y >= round(((noise.get_noise_1d(x+(chunkX*chunkSize.x))+1)/4.0)*chunkSize.y)+50:
					chunks[chunkX][1][x][y] = 0
				if cave.get_noise_3d(x+(chunkX*chunkSize.x),y,4) > 0.21 and chunks[chunkX][0][x][y] != 35 and y >= round(((noise.get_noise_1d(x+(chunkX*chunkSize.x))+1)/4.0)*chunkSize.y)+50:
					chunks[chunkX][0][x][y] = 0
		if toPlace.has(chunkX):
			for i in range(toPlace[chunkX].size()):
				block(str(toPlace[chunkX][i][0]),toPlace[chunkX][i][1],toPlace[chunkX][i][2])
		for x in range(chunkX-1,chunkX+2):
			if x != chunkX and chunks.has(x):
				load_chunk(x)
	load_chunk(chunkX)

func get_biome(pos):
	var temp = temps.get_noise_1d(pos)
	var precipitation = precip.get_noise_1d(pos)
	if temp < 0:
		if precipitation > 0.10:
			return BIOME_TYPES["Frozen Forest"]
		elif precipitation < -0.10:
			return BIOME_TYPES["Frozen Desert"]
		else:
			return BIOME_TYPES["Tundra"]
	if temp > 0:
		if precipitation > 0.10:
			return BIOME_TYPES["Forest"]
		elif precipitation < -0.10:
			return BIOME_TYPES["Desert"]
		else:
			return BIOME_TYPES["Plains"]

# --- Block rendering ---
# Each block is named for identification as ("id,x,y")
func load_chunk(chunkX):
	var wait = true
	while wait:
		if !renderThread.is_active():
			wait = false
			renderThread.start(self,"render_thread",chunkX)
		yield(get_tree().create_timer(0.1),"timeout")

func render_thread(playerChunk):
	var newBlocks = []
	for i in range(-1,2):
		if chunks.has(playerChunk):
			render_chunk(playerChunk+i,newBlocks)
	self.call_deferred("render_done",newBlocks)
	renderThread.call_deferred("wait_to_finish")

func render_chunk(chunkX,block):
	var playerPos = $Player.playerLoadPos
	for x in range(chunkSize.x):
		#yield(get_tree().create_timer(0.01), "timeout")
		for y in range(chunkSize.y):
			var xPos = x + chunkX*chunkSize.x
			if xPos < playerPos.x + LOADRECT.x and xPos > playerPos.x - LOADRECT.x and y < playerPos.y + LOADRECT.y and y > playerPos.y - LOADRECT.y: 
				load_block(chunks[chunkX][1],chunkX,x,y,1,block)
				if block("get",Vector2(xPos,y)) == 0 or ((transparent.has(block("get",Vector2(xPos,y))) or block("get",Vector2(xPos,y)) == 53) and !transparent.has(block("get",Vector2(xPos,y),0))):
					load_block(chunks[chunkX][0],chunkX,x,y,0,block)

func render_done(blocker):
	for i in range(blocker.size()):
		if blocker[i][0] == "New":
			var data = blocker[i][1]
			var block = BLOCK.instance()
			if data["type"] == "Water":
				block = WATER.instance()
				if !$water.water.has([data["position"]/ Vector2(16,16)+Vector2(blocker[i][2]*16,0),data["z"]]):
					$water.water[[data["position"]/ Vector2(16,16)+Vector2(blocker[i][2]*16,0),data["z"]]] = 9
			block.name = data["name"]
			block.position = data["position"]
			block.id = data["id"]
			block.z = data["z"]
			if INTERACTABLE_BLOCK.has(data["id"]): #adds block data to block
				block.containsData = true
			if data["type"] == "Block":
				block.get_node("Sprite").set_material(BLOCKSHADER.duplicate())
			else:
				block.get_node("Sprite").set_material(WATERSHADER.duplicate())
			match data["id"]: #Setting up light sources
				53:
					block.lightEmit = 14
					block.lightSource = true
			$chunks.get_node(str(blocker[i][2])).add_child(block)
#		elif blocker[i][0] == "Remove":
#			if [41,60].has($chunks.get_node(blocker[i][1]).id):
#				$water.water.erase([blocker[i][2]+Vector2(blocker[i][3]*16,0),blocker[i][4]])
#			$chunks.get_node(blocker[i][1]).queue_free()
#			if i < blocker.size()-1 and blocker[i+1][0] == "New" and blocker[i+1][2] == blocker[i][3] and blocker[i+1][1]["position"]/ Vector2(16,16) == blocker[i][2] and blocker[i][4] == blocker[i+1][1]["z"]:
#				yield(get_tree().create_timer(0.1),"timeout")
	if chunksLoaded != -1:
		chunksLoaded += 1
		if chunksLoaded >= 5:
			chunksLoaded = -1
			emit_signal("world_loaded")
	emit_signal("update")

func load_block(chunk,chunkX,x,y,index,blockArray):
	if !$chunks.get_node(str(chunkX)).has_node(str(index) + "," + str(x) + "," + str(y)) and chunk[x][y] > 0:
		var data = {}
		data["type"] = "Block"
		if [41,60].has(chunk[x][y]):
			data["type"] = "Water"
		data["name"] = str(index) + "," + str(x) + "," + str(y)
		data["position"] = Vector2(x*16,y*16)
#		block.globePos = Vector2(chunkX*chunkSize.x+x,y)
		data["id"] = chunk[x][y]
		data["z"] = index
#		if INTERACTABLE_BLOCK.has(chunk[x][y]):
#			data["data"] = interactableBlockData[[Vector2(chunkX*chunkSize.x+x,y),index]]
		blockArray.append(["New",data,chunkX])
	elif $chunks.get_node(str(chunkX)).has_node(str(index) + "," + str(x) + "," + str(y)) and chunk[x][y] == 0:
		blockArray.append(["Remove",str(chunkX) + "/" + str(index) + "," + str(x) + "," + str(y),Vector2(x,y),chunkX,index])
		#$chunks.get_node(str(chunkX) + "/" + str(index) + "," + str(x) + "," + str(y)).queue_free()
	elif $chunks.get_node(str(chunkX)).has_node(str(index) + "," + str(x) + "," + str(y)) and $chunks.get_node(str(chunkX)).get_node(str(index) + "," + str(x) + "," + str(y)).id != chunk[x][y]:
		var data = {}
		data["type"] = "Block"
		if [41,60].has(chunk[x][y]):
			data["type"] = "Water"
		data["name"] = str(index) + "," + str(x) + "," + str(y)
		data["position"] = Vector2(x*16,y*16)
#		block.globePos = Vector2(chunkX*chunkSize.x+x,y)
		data["id"] = chunk[x][y]
		data["z"] = index
#		if INTERACTABLE_BLOCK.has(chunk[x][y]):
#			data["data"] = interactableBlockData[[Vector2(chunkX*chunkSize.x+x,y),index]]
		blockArray.append(["Remove",str(chunkX) + "/" + str(index) + "," + str(x) + "," + str(y),Vector2(x,y),chunkX,index])
		blockArray.append(["New",data,chunkX])

func get_chunk(xPos): return int(floor(xPos/ chunkSize.x))

func chunkify(pos): return Vector2(pos.x-(get_chunk(pos.x)*chunkSize.x),pos.y)

func chunkifyI(x): return x-(get_chunk(x)*chunkSize.x)

func block(action,pos,z=1,test=false): #action: either get or put the block you want to set it to (as a string)
	if pos.y < 128 and pos.y >= 0:
		if chunks.has(get_chunk(pos.x)) and (chunks[get_chunk(pos.x)][0] != [] or z != 0):
			if action == "get":
				if test:
					print(chunks[get_chunk(pos.x)][z][pos.x-(get_chunk(pos.x)*chunkSize.x)][pos.y])
				return chunks[get_chunk(pos.x)][z][pos.x-(get_chunk(pos.x)*chunkSize.x)][pos.y]
			else:
				chunks[get_chunk(pos.x)][z][pos.x-get_chunk(pos.x)*chunkSize.x][pos.y] = int(action)
		else:
			if toPlace.has(get_chunk(pos.x)):
				toPlace[get_chunk(pos.x)].append([int(action),pos,z])
			else:
				toPlace[get_chunk(pos.x)] = [[int(action),pos,z]]

func build_event(action,pos,id,z = 1,itemAction = true):
	var blockAtPos = block("get",pos,z)
	if action == "break":
		if [58].has(blockAtPos): #Drops all items the container has when broken
			var items = interactableBlockData[[get_node("cursor").position/ Vector2(16,16),z]]
			for i in range(items[0].size()):
				$entities.add_item(items[0][i],items[1][i],pos*Vector2(16,16),false)
		if get_node("CanvasLayer/hotbar").can_harvest(blockAtPos):
			var data = block_data[blockAtPos]
			match blockAtPos:
				5:
					if randi()%100 < 10:
						$entities.add_item(57,1,pos*Vector2(16,16),false)
				66:
					if randi()%100 < 10:
						$entities.add_item(67,1,pos*Vector2(16,16),false)
				70:
					if randi()%100 < 10:
						$entities.add_item(71,1,pos*Vector2(16,16),false)
				_:
					if data.drops.size() >= 1 and itemAction:
						for i in range(data.drops.size()):
							$entities.add_item(data.drops[i][0],int(rand_range(data.drops[i][1][0],data.drops[i][1][1]+1)),pos*Vector2(16,16),false)
		block("0",pos,z)
	else:
		block(str(id),pos,z)
		match id:
			23: #furnace data
				interactableBlockData[[pos,z]] = [[0,0,0],[0,0,0],0,0,0] #[[[top id,bottom id,result id],[top num, bottom num, result num]],process,time spent]
			57: #sapling data
				interactableBlockData[[pos,z]] = [0,round(rand_range(120,600))] #[age (120-600 seconds),life]
			58:
				interactableBlockData[[pos,z]] = chestData.duplicate(true)
			62,63:
				interactableBlockData[[pos,z]] = false
			67:
				interactableBlockData[[pos,z]] = [0,round(rand_range(120,600))]
		if itemAction:
			$CanvasLayer/hotbar.remove_from_inventory($CanvasLayer/hotbar/select.selected,1)
		if action == "41":
			$CanvasLayer/hotbar.add_to_inventory(59,1)
	chunks[get_chunk(pos.x)][2] = true #Makes it so chunk is stored in storage even when unloaded
	load_chunk(get_chunk(pos.x))

func _exit_tree():
	if renderThread.is_active():
		renderThread.wait_to_finish()

func _on_Quit_pressed():
	$CanvasLayer/Menu/click.play()
	yield($CanvasLayer/Menu/click,"finished")
	save_game()
	get_tree().change_scene("res://scene/Menu.tscn")
