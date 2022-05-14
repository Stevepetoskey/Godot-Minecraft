extends Node2D

var water = {}

onready var main = get_node("..")

signal waterUpdate

func _on_Node2D_world_loaded():
	pass
	#$Timer.start()

func _on_Timer_timeout():
	var updated = []
	var alreadySpread = []
	for x in range((get_node("../Player").playerChunk-2)*get_node("..").chunkSize.x,(get_node("../Player").playerChunk+3)*get_node("..").chunkSize.x):
		for y in range(get_node("..").chunkSize.y):
			if water.has([Vector2(x,y),1]) and !alreadySpread.has([Vector2(x,y),1]):
				var value = water[[Vector2(x,y),1]]
				if value != 9 and !((water.has([Vector2(x,y-1),1]) and water[[Vector2(x,y-1),1]] > 0) or (water.has([Vector2(x-1,y),1]) and water[[Vector2(x-1,y),1]] > value) or (water.has([Vector2(x+1,y),1]) and water[[Vector2(x+1,y),1]] > value)):
					if water[[Vector2(x,y),1]] == 8:
						water[[Vector2(x,y),1]] -= 6
					water[[Vector2(x,y),1]] -= 1
				if water[[Vector2(x,y),1]] <= 0:
					water.erase([Vector2(x,y),1])
					main.block("0",Vector2(x,y))
					if !updated.has(main.get_chunk(x)):
						updated.append(main.get_chunk(x))
				else:
					if water[[Vector2(x,y),1]] != 9 and water.has([Vector2(x-1,y),1]) and water[[Vector2(x-1,y),1]] == 9 and water.has([Vector2(x+1,y),1]) and water[[Vector2(x-1,y),1]] == 9:
						water[[Vector2(x,y),1]] = 9
						main.block("41",Vector2(x,y))
						if !updated.has(main.get_chunk(x)):
							updated.append(main.get_chunk(x))
					if water.has([Vector2(x,y-1),1]) and water[[Vector2(x,y-1),1]] > 0:
						water[[Vector2(x,y),1]] == 8
					value = water[[Vector2(x,y),1]]
					var valuePass = value-1
					if value == 9:
						value = 7
					spread(x,y+1,alreadySpread,updated,valuePass,true)
					if ![41,60,0].has(main.block("get",Vector2(x,y+1))):
						spread(x+1,y,alreadySpread,updated,valuePass)
						spread(x-1,y,alreadySpread,updated,valuePass)
	for chunkX in updated:
		if get_node("../chunks").has_node(str(chunkX)):
			main.load_chunk(chunkX)
	emit_signal("waterUpdate")

func spread(x,y,spreadData,chunkLoad,valueToPass,down = false):
	if main.block("get",Vector2(x,y)) == 0:
		if down:
			water[[Vector2(x,y),1]] = 8
		else:
			water[[Vector2(x,y),1]] = valueToPass
		main.block("60",Vector2(x,y))
		spreadData.append([Vector2(x,y),1])
		if !chunkLoad.has(main.get_chunk(x)):
			chunkLoad.append(main.get_chunk(x))
	elif !down and main.block("get",Vector2(x,y)) == 60 and water[[Vector2(x,y),1]] < valueToPass:
		water[[Vector2(x,y),1]] = valueToPass
