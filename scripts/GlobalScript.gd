extends Node

const CURRENTVER = "0.4.0 pre 2"
const STABLE = false

var savegame = File.new() #file
var save_path = "user://saves/" #place of the file
var save_data

var gamemode = "Survival"
var worldSeed = 0
var worldType = "Default"
var worldNamePath = "newWorld"
var new_data = {"nothing":0}
var new = false

var character = {}

func get_from_json(fileName):
	var file = File.new()
	file.open(fileName, File.READ)
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	return data

func unfloat_2d(array):
	for x in range(array.size()):
		for y in range(array[x].size()):
			if typeof(array[x][y]) == TYPE_REAL:
				array[x][y] = int(array[x][y])

func unfloat(array):
	for i in range(array.size()):
		if typeof(array[i]) == TYPE_REAL:
			array[i] = int(array[i])

func new_world(worldName):
	var dir = Directory.new()
	if !Directory.new().dir_exists(save_path):
		dir.open("user://")
		dir.make_dir("saves")
#	var img = Image.new()
	worldName.replace("/","")
	worldName.replace(".","")
	while Directory.new().dir_exists(save_path + worldName):
		worldName = worldName + "_"
	worldNamePath = worldName
	dir.open(save_path)
	dir.make_dir(worldName)
#	img.create(99,60,false,Image.FORMAT_RGBA8)
#	img.save_png(save_path + islandName + "/Island.png")
	savegame.open(save_path + worldName + "/" + worldName, File.WRITE)
	savegame.store_var(new_data)
	new = true
	savegame.close()
	
#func _ready():
#	new_data = get_from_json("Json Data/NewWorld.json")
#	unfloat_2d(new_data["islandBack"])
#	new_data["gamemode"] = 0
#	unfloat(new_data["inventory"])
#	unfloat(new_data["inventoryNum"])

func save(data):
	data["Ver"] = CURRENTVER
	data["Stable"] = STABLE
	save_data = data #data to save
	savegame.open(save_path + worldNamePath + "/" + worldNamePath, File.WRITE) #open file to write
	savegame.store_var(save_data) #store the data
	savegame.close() # close the file
	print("Saved Game!")
	
func read_savegame():
	savegame.open(save_path + worldNamePath + "/" + worldNamePath, File.READ) #open the file
	save_data = savegame.get_var() #get the value
	savegame.close() #close the file
	return save_data #return the value

func remove_recursive(path): #Credit to davidepesce.com for this function. It deletes all the files in the main file, which allows it to delete the main one safely
	var directory = Directory.new()
	
	# Open directory
	var error = directory.open(path)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_recursive(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		# Remove current path
		directory.remove(path)
	else:
		print("Error removing " + path)
