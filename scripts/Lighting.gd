extends Node2D

const LightRect = Vector2(46,36) #The size of the calculation box (around the player) normal: (44,32)

var lightThread = Thread.new() #The lighting thread. This is the seperate thread that calculates all the light data at any given time
var prePlayerPos = Vector2(0,0) #The position the player was at before the thread started

var lightArray = []
var transparent = [0,5,41,43,54,58,60,62,63,66,70,94]
var solidTrans = [53,80,97,98,99,100,101,102,103]
var ambientLevel = 15
var calls = []
var callAmount = 0
var updated = []
var worldLoaded = false
var playerLoaded = false
var lostLevel = 85

var day = true
onready var main = get_node("..")
onready var sky = get_node("../CanvasLayer/ParallaxBackground/Sky/Sky")

func vec2_round(vec2): return(Vector2(int(round(vec2.x)),int(round(vec2.y))))

func get_light_level(pos):
	var lightPosition = pos - vec2_round(get_node("../Player").position/ Vector2(16,16)) + Vector2(LightRect.x/2,LightRect.y/2)
	return lightArray[lightPosition.x][lightPosition.y]

func get_layer(pos,includeTransparent = false):
	var block = get_node("..").block("get",pos,1)
	if (!includeTransparent and transparent.has(block)) or (includeTransparent and block == 0):
		return 0
	return 1

func get_drop_off(lightPos,firstPos,value):
	if (value == ambientLevel and transparent.has(get_node("..").block("get",firstPos,1)) and transparent.has(get_node("..").block("get",firstPos,0)) and firstPos.y < 90 and !(transparent.has(get_node("..").block("get",lightPos,1)) and transparent.has(get_node("..").block("get",lightPos,0)))) or (main.block("get",firstPos,get_layer(firstPos)) != 0 and main.block_data[main.block("get",firstPos,get_layer(firstPos))].lightSource):
		return 0
	if transparent.has(get_node("..").block("get",lightPos,1)):
		return 1
	return 3

func can_propigate(pos1,pos2):
	var block = main.block("get",pos1,get_layer(pos1))
	if get_layer(pos1) == get_layer(pos2) or get_layer(pos1) == 0 or (block != null and main.block_data[block].lightSource):
		return true

#Initializes the light array based off of the dimensions stated in LightRect
func _ready():
	for x in range(LightRect.x):
		lightArray.append([])
		for y in range(LightRect.y):
			lightArray[x].append(0)

func _process(delta):
	render()
	var cursorPos = vec2_round(get_node("../cursor").position / Vector2(16,16)) - vec2_round(get_node("../Player").position/ Vector2(16,16)) + Vector2(LightRect.x/2,LightRect.y/2)
	if cursorPos.y < 128 and cursorPos.y >= 0:
		get_node("../CanvasLayer/Label").text = "Light Level: " + str(lightArray[cursorPos.x][cursorPos.y])

#Starts the calculations of the light around the player
func render():
#	print(!lightThread.is_active(),worldLoaded,playerLoaded)
	if !lightThread.is_active() and worldLoaded and playerLoaded:
		prePlayerPos = get_node("../Player").position
		lightThread.start(self,"prep_light",lightArray.duplicate(true),1)

#Sets everything to zero, or a light value depending on if it is a light source or not. This helps stop light calculations wasting time by calculating a path that will be eventually be written over by another light source
func prep_light(data): #threadLight is what will replace the main lightArray when the thread is finished calculating
	var threadLight = data
	for x in range(LightRect.x):
		for y in range(LightRect.y):
			var pos = vec2_round(prePlayerPos/ Vector2(16,16)) - Vector2(LightRect.x/2,LightRect.y/2) + Vector2(x,y) #This formula just makes the light array rectangle in the game
			if pos.y >= 0 and pos.y < main.chunkSize.y:
				var block = main.block("get",pos)
				var backBlock = main.block("get",pos,0)
				if transparent.has(block):
					if transparent.has(backBlock):
						if pos.y < lostLevel: #normal 90; level at which ambient light is lost
							threadLight[x][y] = ambientLevel
						else:
							threadLight[x][y] = 0
					else:
						threadLight[x][y] = 0
						if backBlock != null and main.block_data[backBlock].lightSource:
							threadLight[x][y] = main.block_data[backBlock].lightEmit
				else:
					threadLight[x][y] = 0
					if block != null and main.block_data[block].lightSource:
						threadLight[x][y] = main.block_data[block].lightEmit
	
	var firstLight = threadLight.duplicate(true)
	for x in range(LightRect.x):
		for y in range(LightRect.y):
			var pos = vec2_round(prePlayerPos/ Vector2(16,16)) - Vector2(LightRect.x/2,LightRect.y/2) + Vector2(x,y)
			if pos.y >= 0 and pos.y < main.chunkSize.y:
				if firstLight[x][y] > 0 and ((x-1 >= 0 and threadLight[x-1][y] < 15) or (x+1 < LightRect.x and threadLight[x+1][y] < 15) or (y+1 < LightRect.y and threadLight[x][y+1] < 15) or (y-1 >= 0 and threadLight[x][y-1] < 15)):
					update_light(Vector2(x,y),pos,threadLight[x][y],get_layer(pos),threadLight)
	self.call_deferred("thread_done",threadLight)
	lightThread.call_deferred("wait_to_finish")

func update_light(arrPos,pos,value,layer,threadLight):
	threadLight[arrPos.x][arrPos.y] = value
	if value-get_drop_off(pos,pos,value) > 0:
		if arrPos.x+1 < LightRect.x and can_propigate(pos,pos+Vector2(1,0)) and value > threadLight[arrPos.x+1][arrPos.y]+get_drop_off(pos+Vector2(1,0),pos,value):
			update_light(arrPos+Vector2(1,0),pos+Vector2(1,0),value-get_drop_off(pos+Vector2(1,0),pos,value),get_layer(pos+Vector2(1,0)),threadLight)
		if arrPos.x-1 >= 0 and can_propigate(pos,pos-Vector2(1,0)) and value > threadLight[arrPos.x-1][arrPos.y]+get_drop_off(pos-Vector2(1,0),pos,value):
			update_light(arrPos-Vector2(1,0),pos-Vector2(1,0),value-get_drop_off(pos-Vector2(1,0),pos,value),get_layer(pos-Vector2(1,0)),threadLight)
		if pos.y+1 < main.chunkSize.y and arrPos.y+1 < LightRect.y and can_propigate(pos,pos+Vector2(0,1)) and value > threadLight[arrPos.x][arrPos.y+1]+get_drop_off(pos+Vector2(0,1),pos,value):
			update_light(arrPos+Vector2(0,1),pos+Vector2(0,1),value-get_drop_off(pos+Vector2(0,1),pos, value),get_layer(pos+Vector2(0,1)),threadLight)
		if pos.y-1 >= 0 and arrPos.y-1 >= 0 and can_propigate(pos,pos-Vector2(0,1)) and value > threadLight[arrPos.x][arrPos.y-1]+get_drop_off(pos-Vector2(0,1),pos,value):
			update_light(arrPos-Vector2(0,1),pos-Vector2(0,1),value-get_drop_off(pos-Vector2(0,1),pos , value),get_layer(pos-Vector2(0,1)),threadLight)

func thread_done(threadLight):
	lightArray = threadLight.duplicate(true)
	for x in range(10,LightRect.x-9):
		for y in range(10,LightRect.y-9):
			var pos = vec2_round(prePlayerPos/ Vector2(16,16)) - Vector2(LightRect.x/2,LightRect.y/2) + Vector2(x,y)
			if get_node("../chunks").has_node(str(main.get_chunk(pos.x))):
				if get_node("../chunks").get_node(str(main.get_chunk(pos.x))).has_node(str(get_layer(pos,true))+","+str(main.chunkify(pos).x)+","+str(pos.y)):
					var test = Sprite.new()
					get_node("../chunks").get_node(str(main.get_chunk(pos.x))).get_node(str(get_layer(pos,true))+","+str(main.chunkify(pos).x)+","+str(pos.y)+"/Sprite").material.set_shader_param("shade",lightArray[x][y]/15.0)
#					if main.block("get",pos) == 54:
#						print(get_layer(pos) > 0, " , ", (transparent.has(main.block("get",pos)) or main.block("get",pos) == 53) , " , ", !transparent.has(main.block("get",pos,0)))
					if get_node("../chunks").get_node(str(main.get_chunk(pos.x))).has_node("0,"+str(main.chunkify(pos).x)+","+str(pos.y)) and get_layer(pos,true) > 0 and (transparent.has(main.block("get",pos)) or solidTrans.has(main.block("get",pos))) and !transparent.has(main.block("get",pos,0)):
						get_node("../chunks").get_node(str(main.get_chunk(pos.x))).get_node("0"+","+str(main.chunkify(pos).x)+","+str(pos.y)+"/Sprite").material.set_shader_param("shade",lightArray[x][y]/15.0)

func _on_Daylight_Cycle_timeout():
	var skyColor = sky.material.get_shader_param("color")
	var scale = 1
	var color1 = Vector3(2,1,0.75)
	var color2 = Vector3(1,1,1.2)
	if day:
		scale = -1
		color1 = Vector3(3,1,0.75)
		color2 = Vector3(0.2,0.1,0.2)
	var j = 1
	for i in range(11):
		for k in range(10):
			if j <= 55:
				sky.material.set_shader_param("color",lerp(skyColor,color1,j/55.0))
				if j == 55:
					skyColor = color1
			else:
				sky.material.set_shader_param("color",lerp(skyColor,color2,(j-55)/55.0))
			yield(get_tree().create_timer(60.0/110), "timeout")
			j += 1
		ambientLevel += scale
		if scale == -1 and ambientLevel == 7:
			get_node("../entities").fill_entities()
	day = !day
	$DaylightCycle.start()

func _exit_tree():
	if lightThread.is_active():
		lightThread.wait_to_finish()

func _on_Node2D_world_loaded():
	worldLoaded = true
	$DaylightCycle.start()
