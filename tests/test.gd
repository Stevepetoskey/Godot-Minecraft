extends Node2D

var thread = Thread.new()
var lightArray = ["lightyes",[0,null]]

var object = preload("res://assets/block.tscn")
var SHADER = preload("res://shaders/block.tres")
const BLOCK = preload("res://assets/block.tscn")

var guh = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var craft = [8,8,0,
				 8,8,0,
				 8,8,0]
	var result = [62,3]
	var loc = 0
	var orgin = Vector2(-1,-1)
	var crafting = []
	for y in range(3):
		for x in range(3):
			if craft[loc] > 0 and orgin == Vector2(-1,-1):
				orgin = Vector2(x,y)
				crafting.append([Vector2(0,0),craft[loc]])
			elif craft[loc] > 0:
				crafting.append([Vector2(x,y)-orgin,craft[loc]])
			loc += 1
	var system = "["
	for i in range(crafting.size()):
		var vec = "Vector2" + str(crafting[i][0]) + "," + str(crafting[i][1])
		system += "[" + vec + "]"
		if i < crafting.size()-1:
			system += ","
	system += "]"
	var final = "[" + system + ", " + str(result) + "],"
	print(final)
	var files = [0,4,6,2,5]
	for i in range(1,files.size()):
		var current = i
		var stop = false
		while !stop:
			if files[current] < files[current-1]:
				var small = files[current] #might need dupe
				files[current] = files[current-1]
				files[current-1] = small
				if current > 1:
					current -= 1
				else:
					stop = true
			else:
				stop = true
	print(files)
	print("random test")
	for i in range(20):
		print(int(rand_range(1,3+1)))

func optimal():
	var time = OS.get_ticks_msec()
	for i in range(125):
		var block = BLOCK.instance()
		add_child(block)
	print("Optimal: " + str(OS.get_ticks_msec()-time))

func render_done():
	var time = OS.get_ticks_msec()
	for i in range(32):
		if "New" == "New":
			var block = BLOCK.instance()
			block.name = "324e34"
			block.position = Vector2(i*16,0)
			block.id = 1
			block.z = 1
			if true:
				block.get_node("Sprite").set_material(SHADER.duplicate())
			add_child(block)
	print("Real: " + str(OS.get_ticks_msec()-time))


func _on_Timer_timeout():
	print(guh)
	guh += 1
