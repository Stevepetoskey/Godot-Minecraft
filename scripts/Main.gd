extends Node2D

const chunkSize = Vector2(16,128)
const WATERLEVEL = 85
const LOADRECT = Vector2(16,11) #Normal (14,9)
const BLOCK = preload("res://assets/block.tscn")
const BLOCKSHADER = preload("res://shaders/block.tres")
const WATERSHADER = preload("res://shaders/Water.tres")
const WATER = preload("res://assets/Water.tscn")
const INTERACTABLE_BLOCK = [23,57,62,63]

var chestData = [[],[]]
var newData = {"Entity":[],"Player":[Vector2(0,0),20,600,Vector2(0,0),false,0,true]}

var chunks = {} #ChunkX: [Foreground,background,modified,already Spawned]
var toPlace = {} #ChunkX: [[block id, loc]]
var interactableBlockData = {}
var renderThread = Thread.new()
var updating = false
var noise = OpenSimplexNoise.new()
var temps = OpenSimplexNoise.new()
var cave = OpenSimplexNoise.new()
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
var trees = {"normal": [[0,0,5],[0,5,5],[5,5,5],[0,0,5],[0,0,0]]} #[x[y]]
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
	var json_block_data = {
"0":{"name": "Air",
	"id": 0,
	"mined_by": 0,
	"block_hardness": -1,
	"can_harvest": ["none"],
	"drops": [0],
	"texture": "",
	"sound_file_name": ""
	},
"1":{"name": "Grass block",
	"id": 0,
	"mined_by": 1,
	"block_hardness": 0.6,
	"can_harvest": ["all"],
	"drops": [[2,[1,1]]],
	"texture": "grass_block",
	"sound_file_name": "grass"
	},
"2":{"name": "Dirt",
	"id": 2,
	"mined_by": 1,
	"block_hardness": 0.5,
	"can_harvest": ["all"],
	"drops": [[2,[1,1]]],
	"texture": "dirt",
	"sound_file_name": "gravel"
	},
"3":{"name": "Stone",
	"id": 3,
	"mined_by": 2,
	"block_hardness": 1.5,
	"can_harvest": ["allType"],
	"drops": [[13,[1,1]]],
	"texture": "stone",
	"sound_file_name": "stone"
	},
"4":{"name": "Oak log",
	"id": 4,
	"mined_by": 3,
	"block_hardness": 2,
	"can_harvest": ["all"],
	"drops": [[4,[1,1]]],
	"texture": "oak_log",
	"sound_file_name": "wood"
	},
"5":{"name": "Oak leaves",
	"id": 5,
	"mined_by": 0,
	"block_hardness": 0.2,
	"can_harvest": ["all"],
	"drops": [0],
	"texture": "oak_leaves",
	"sound_file_name": "grass"
	},
"6":{"name": "Coal ore",
	"id": 6,
	"mined_by": 2,
	"block_hardness": 3,
	"can_harvest": ["allType"],
	"drops": [[15,[1,1]]],
	"texture": "coal_ore",
	"sound_file_name": "stone"
	},
"7":{"name": "Iron ore",
	"id": 7,
	"mined_by": 2,
	"block_hardness": 3,
	"can_harvest": ["stone","iron","diamond","gold","netherite"],
	"drops": [[7,[1,1]]],
	"texture": "iron_ore",
	"sound_file_name": "stone"
	},
"8":{"name": "Oak planks",
	"id": 8,
	"mined_by": 3,
	"block_hardness": 2,
	"can_harvest": ["all"],
	"drops": [[8,[1,1]]],
	"texture": "oak_planks",
	"sound_file_name": "wood"
	},
"10":{"name": "Crafting table",
	"id": 10,
	"mined_by": 3,
	"block_hardness": 3.75,
	"can_harvest": ["all"],
	"drops": [[10,[1,1]]],
	"texture": "crafting_table",
	"sound_file_name": "wood"
	},
"13":{"name": "Cobblestone",
	"id": 13,
	"mined_by": 2,
	"block_hardness": 2,
	"can_harvest": ["allType"],
	"drops": [[13,[1,1]]],
	"texture": "cobblestone",
	"sound_file_name": "stone"
	},
"23":{"name": "Furnace",
	"id": 23,
	"mined_by": 2,
	"block_hardness": 3.5,
	"can_harvest": ["allType"],
	"drops": [[23,[1,1]]],
	"texture": "furnace_front",
	"sound_file_name": "stone"
	},
"25":{"name": "Coal block",
	"id": 25,
	"mined_by": 2,
	"block_hardness": 5,
	"can_harvest": ["allType"],
	"drops": [[25,[1,1]]],
	"texture": "coal_block",
	"sound_file_name": "stone"
	},
"26":{"name": "Iron block",
	"id": 26,
	"mined_by": 2,
	"block_hardness": 5,
	"can_harvest": ["stone","iron","diamond","gold","netherite"],
	"drops": [[26,[1,1]]],
	"texture": "iron_block",
	"sound_file_name": "stone"
	},
"27":{"name": "Diamond ore",
	"id": 27,
	"mined_by": 2,
	"block_hardness": 3,
	"can_harvest": ["iron","diamond","netherite"],
	"drops": [[34,[1,1]]],
	"texture": "diamond_ore",
	"sound_file_name": "stone"
	},
"28":{"name": "Diamond block",
	"id": 28,
	"mined_by": 2,
	"block_hardness": 5,
	"can_harvest": ["iron","daimond","netherite"],
	"drops": [[28,[1,1]]],
	"texture": "diamond_block",
	"sound_file_name": "stone"
	},
"35":{"name": "Bedrock",
	"id": 35,
	"mined_by": 0,
	"block_hardness": -1,
	"can_harvest": ["none"],
	"drops": [[35,[1,1]]],
	"texture": "bedrock",
	"sound_file_name": "stone"
	},
"41":{"name": "Water",
	"id": 41,
	"mined_by": 0,
	"block_hardness": -1,
	"can_harvest": ["none"],
	"drops": [[41,[1,1]]],
	"texture": "water_still",
	"sound_file_name": ""
	},
"42":{"name": "Sand",
	"id": 42,
	"mined_by": 1,
	"block_hardness": 0.5,
	"can_harvest": ["all"],
	"drops": [[42,[1,1]]],
	"texture": "sand",
	"sound_file_name": "sand"
	},
"43":{"name": "Glass",
	"id": 43,
	"mined_by": 0,
	"block_hardness": 0.3,
	"can_harvest": ["all"],
	"drops": [0],
	"texture": "glass",
	"sound_file_name": "glass"
	},
"44":{"name": "Sandstone",
	"id": 44,
	"mined_by": 2,
	"block_hardness": 0.8,
	"can_harvest": ["allType"],
	"drops": [[44,[1,1]]],
	"texture": "sandstone",
	"sound_file_name":  "stone"
	},
"45":{"name": "Snow block",
	"id": 45,
	"mined_by": 1,
	"block_hardness": 0.2,
	"can_harvest": ["allType"],
	"drops": [[46,[1,4]]],
	"texture": "snow",
	"sound_file_name": "snow"
	},
"48":{"name": "Clay block",
	"id": 48,
	"mined_by": 1,
	"block_hardness": 0.6,
	"can_harvest": ["all"],
	"drops": [[47,[1,4]]],
	"texture": "clay",
	"sound_file_name": "gravel"
	},
"50":{"name": "Bricks",
	"id": 50,
	"mined_by": 2,
	"block_hardness": 2,
	"can_harvest": ["allType"],
	"drops": [[50,[1,1]]],
	"texture": "bricks",
	"sound_file_name": "stone"
	},
"51":{"name": "Smooth stone",
	"id": 51,
	"mined_by": 2,
	"block_hardness": 2,
	"can_harvest": ["allType"],
	"drops": [[51,[1,1]]],
	"texture": "smooth_stone",
	"sound_file_name": "stone"
	},
"52":{"name": "Stone bricks",
	"id": 52,
	"mined_by": 2,
	"block_hardness": 1.5,
	"can_harvest": ["allType"],
	"drops": [[52,[1,1]]],
	"texture": "stone_bricks",
	"sound_file_name": "stone"
	},
"53":{"name": "Torch",
	"id": 53,
	"mined_by": 0,
	"block_hardness": 0.01,
	"can_harvest": ["all"],
	"drops": [[53,[1,1]]],
	"texture": "torch",
	"sound_file_name": "wood",
	"light_source": true,
	"light_value":14
	},
"54":{"name": "Ladder",
	"id": 54,
	"mined_by": 3,
	"block_hardness": 0.4,
	"can_harvest": ["all"],
	"drops": [[54,[1,1]]],
	"texture": "ladder",
	"sound_file_name": "wood"
	},
"57":{"name": "Oak sapling",
	"id": 57,
	"mined_by": 0,
	"block_hardness": 0.01,
	"can_harvest": ["all"],
	"drops": [[57,[1,1]]],
	"texture": "oak_sapling",
	"sound_file_name": "grass"
	},
"58":{"name": "Chest",
	"id": 58,
	"mined_by": 3,
	"block_hardness": 2.5,
	"can_harvest": ["all"],
	"drops": [[58,[1,1]]],
	"texture": "chest/normal_closed",
	"sound_file_name": "wood"
	},
"60":{"name": "Flowing water",
	"id": 60,
	"mined_by": 0,
	"block_hardness": -1,
	"can_harvest": ["none"],
	"drops": [0],
	"texture": "",
	"sound_file_name": ""
	},
"62":{"name": "Door",
	"id": 62,
	"mined_by": 3,
	"block_hardness": 3,
	"can_harvest": ["all"],
	"drops": [[62,[1,1]]],
	"texture": "oak_door_bottom",
	"sound_file_name": "wood"
	},
"63":{"name": "Door top",
	"id": 63,
	"mined_by": 3,
	"block_hardness": 3,
	"can_harvest": ["all"],
	"drops": [[62,[1,1]]],
	"texture": "oak_door_top",
	"sound_file_name": "wood"
	}
}
	for blockData in json_block_data:
		var data = json_block_data[blockData]
		if !data.has("light_source"):
			block_data[int(blockData)] = block.new(data["name"],int(data["id"]),int(data["mined_by"]),data["block_hardness"],data["can_harvest"],data["drops"],data["texture"],data["sound_file_name"])
		else:
			block_data[int(blockData)] = block.new(data["name"],int(data["id"]),int(data["mined_by"]),data["block_hardness"],data["can_harvest"],data["drops"],data["texture"],data["sound_file_name"],data["light_source"],data["light_value"])
	#Loads sound data
	var json_sound_data = {
"grass":{
	"step": "step/grass",
	"dig": "step/grass",
	"break":"dig/grass",
	"fall":"step/grass",
	"place":"dig/grass",
	},
"gravel":{
	"step": "step/gravel",
	"dig": "step/gravel",
	"break":"dig/gravel",
	"fall":"step/gravel",
	"place":"dig/gravel"
	},
"stone":{
	"step": "step/stone",
	"dig": "step/stone",
	"break":"dig/stone",
	"fall":"step/stone",
	"place":"dig/stone"
	},
"wood":{
	"step": "step/wood",
	"dig": "step/wood",
	"break":"dig/wood",
	"fall":"step/wood",
	"place":"dig/wood"
	},
"sand":{
	"step": "step/sand",
	"dig": "step/sand",
	"break":"dig/sand",
	"fall":"step/sand",
	"place":"dig/sand"
	},
"glass":{
	"step": "step/stone",
	"dig": "step/stone",
	"break":"random/glass",
	"fall":"step/stone",
	"place":"dig/stone"
	},
"snow":{
	"step": "step/snow",
	"dig": "step/snow",
	"break":"dig/snow",
	"fall":"step/snow",
	"place":"dig/snow"
	},
}
	for soundi in json_sound_data:
		var data = json_sound_data[soundi]
		sound_data[soundi] = sound.new(data["step"],data["dig"],data["break"],data["fall"],data["place"])
	#Loads number of audio files per sound
	sound_amount = {
"step/grass":6,
"dig/grass":4,
"step/gravel":4,
"dig/gravel":4,
"step/stone":6,
"dig/stone":4,
"step/wood":6,
"dig/wood":4,
"step/sand":5,
"dig/sand":4,
"random/glass":3,
"step/snow":4,
"dig/snow":4
}
	
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
	noise.seed = worldSeed
	noise.period = 256
	noise.seed = randi()
	noise.lacunarity = 5.0
	temps.seed = randi()
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
				for x in range(chunkSize.x):
					for y in range(chunkSize.y):
						var height = round(((noise.get_noise_1d(x+(chunkX*chunkSize.x))+1)/4.0)*chunkSize.y)+50
						var biome = get_biome(x+(chunkX*chunkSize.x))
						if y < height and y > WATERLEVEL:
							chunk[x][y] = 41
						if y >= height:
							if y > height+randi()%3+1:
								chunk[x][y] = 3
							else:
								if y > height or (y==height and y >= WATERLEVEL+2):
									chunk[x][y] = [2,42,2][biome]
								else:
									if randi()%10 == 1 and biome == 0:
										var treeH = randi()%6+4
										for h in range(1,treeH):
											block("4",Vector2(chunkX*chunkSize.x+x,y-h),0)
										treeH = y-treeH
										for tX in range(5):
											for tY in range(2,-1,-1):
												if trees["normal"][tX][tY] > 1 and block("get",Vector2(chunkX*chunkSize.x+x+(tX-2),tY+treeH)) == 0:
													block("5",Vector2(chunkX*chunkSize.x+x+(tX-2),tY+treeH))
									chunk[x][y] = [1,42,45][biome]
				#yield(get_tree().create_timer(0.01), "timeout")
				for x in range(chunkSize.x):
					var height = round(((noise.get_noise_1d(x+(chunkX*chunkSize.x))+1)/4.0)*chunkSize.y)+50
					for y in range(chunkSize.y):
						if y > WATERLEVEL+3 and y > height and y <= height + 3 and randi()%10 == 1:
							for x2 in range(x-5,x+5):
								for y2 in range(y-5,y+5):
									if randi() % (int(abs(x2-x)+abs(y2-y))+1) == 1:
										if [1,2].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
											block("42",Vector2(chunkX*chunkSize.x+x2,y2),1)
										elif [3].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
											block("44",Vector2(chunkX*chunkSize.x+x2,y2))
						if y > WATERLEVEL+3 and y > height and y <= height + 3 and randi()%20 == 1:
							for x2 in range(x-5,x+5):
								for y2 in range(y-5,y+5):
									if randi() % (int(abs(x2-x)+abs(y2-y))+1) == 1:
										if [1,2].has(block("get",Vector2(chunkX*chunkSize.x+x2,y2))):
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
		if toPlace.has(chunkX):
			for i in range(toPlace[chunkX].size()):
				block(str(toPlace[chunkX][i][0]),toPlace[chunkX][i][1],toPlace[chunkX][i][2])
		for x in range(chunkX-1,chunkX+2):
			if x != chunkX and chunks.has(x):
				load_chunk(x)
	load_chunk(chunkX)

func get_biome(pos):
	var temp = temps.get_noise_1d(pos)
	if temp < -0.25:
		return 2
	if temp > 0.25:
		return 1
	else:
		return 0

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
			if blockAtPos == 5:
				if randi()%100 < 10:
					$entities.add_item(57,1,pos*Vector2(16,16),false)
			elif data.drops.size() >= 1 and itemAction:
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
