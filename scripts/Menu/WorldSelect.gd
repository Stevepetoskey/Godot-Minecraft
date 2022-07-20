extends Control

const FILEBUTTON = preload("res://assets/WorldSelect.tscn")

var savePath = "user://saves/"
var page = 0
var worldPathSelected = null
var gamemodes = ["Survival","Creative"]
var gamemodeTab = 0
var worldTypes = ["Default","Flat"]
var worldTypeTab = 0

onready var globals = get_node("/root/GlobalScript")

func letter_to_int(letter : String): return ord(letter.to_upper()) - ord('A')

func list_files(path): #Gets all the files in a certain path (Only returns their path)
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif !file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func get_save(path): #Gets data of save at path
	var saveGame = File.new()
	saveGame.open(savePath + path + "/" + path, File.READ)
	var save_data = saveGame.get_var()
	saveGame.close()
	return save_data

func load_icons(): #Loads the buttons for each save
	for child in $LoadWorld/worldSelects.get_children():
		child.queue_free()
	yield(get_tree(), "idle_frame")
	var files = list_files(savePath)
	print(files)
	var file = File.new()
	for i in range(1,files.size()):
		var current = i
		var stop = false
		while !stop:
			if OS.get_unix_time() - file.get_modified_time(savePath + "/" + files[current] + "/" + files[current]) < OS.get_unix_time() - file.get_modified_time(savePath + "/" + files[current-1] + "/" + files[current-1]):
				var small = files[current] #might need dupe
				files[current] = files[current-1]
				files[current-1] = small
				if current > 1:
					current -= 1
				else:
					stop = true
			else:
				stop = true
		
	if files.size() > 0:
		var y = 40
		for i in range(files.size()):
			if i%3 == 0: #If max files on screen, make new screen
				var panelSlot = Node2D.new()
				panelSlot.visible = false
				$LoadWorld/worldSelects.add_child(panelSlot)
				y = 40
			var fileButton = FILEBUTTON.instance()
			var saveData = get_save(files[i])
			fileButton.get_node("DisplayName").text = files[i]
			if saveData.has("Name"):
				fileButton.get_node("DisplayName").text = saveData["Name"]
			var ver = "unkown version"
			if saveData.has("Ver"):
				ver = saveData["Ver"]
#			var searchFile = File.new()
#			searchFile.open(savePath + "/" + files[i],File.READ)
			var date = OS.get_datetime_from_unix_time(File.new().get_modified_time(savePath + "/" + files[i] + "/" + files[i]))
			if date["minute"] < 10:
				date["minute"] = "0" + str(date["minute"])
			var dateMod = str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]) + " " + str(date["hour"]) + ":" + str(date["minute"])
			fileButton.get_node("FileData").text = files[i] + " (" + dateMod + ")\nSurvival " + ver
			fileButton.rect_position = Vector2(65,y)
			$LoadWorld/worldSelects.get_child(floor(i/3)).add_child(fileButton)
			y += 30
		print($LoadWorld/worldSelects.get_child_count())
		if page > $LoadWorld/worldSelects.get_child_count()-1:
			page = $LoadWorld/worldSelects.get_child_count()-1
			print(page)
		$LoadWorld/worldSelects.get_child(page).show()
		update_buttons()

func update_buttons():
	get_node("../../Click").play()
	if $LoadWorld/worldSelects.get_child_count() > page+1:
		$LoadWorld/ArrowR.show()
	else:
		$LoadWorld/ArrowR.hide()
	if page > 0:
		$LoadWorld/ArrowL.show()
	else:
		$LoadWorld/ArrowL.hide()

func _on_New_World_pressed():
	worldTypeTab = 0
	gamemodeTab = 0
	get_node("../../Click").play()
	$LoadWorld.hide()
	$NewWorld.show()

func _on_Back_pressed():
	get_node("../../Click").play()
	$NewWorld.hide()
	$LoadWorld.show()

func _on_Create_pressed(): #creates new world
	randomize()
	get_node("../../Click").play()
	yield(get_node("../../Click"),"finished")
	var worldSeed = $NewWorld/Seed.text
	var numSeed = ""
	for i in range(worldSeed.length()):
		if !worldSeed.substr(i,1).is_valid_integer():
			numSeed += str(letter_to_int(worldSeed.substr(i,1)))
		else:
			numSeed += worldSeed.substr(i,1)
	numSeed = int(numSeed)
	if worldSeed.empty():
		numSeed = randi()
	globals.worldSeed = numSeed
	globals.worldType = worldTypes[worldTypeTab]
	globals.gamemode = gamemodes[gamemodeTab]
	globals.new_world($NewWorld/LineEdit.text)
	get_tree().change_scene("res://scene/Main.tscn")

func _on_play_pressed(): #Loads world from save
	get_node("../../Click").play()
	yield(get_node("../../Click"),"finished")
	if worldPathSelected != null:
		if !get_save(worldPathSelected).has("Ver"):
			$LoadWorld/Warning2.show()
		elif get_save(worldPathSelected)["Stable"] and !globals.STABLE:
			$LoadWorld/Warning.show()
		else:
			globals.worldNamePath = worldPathSelected
			globals.new = false
			get_tree().change_scene("res://scene/Main.tscn")

func _on_ArrowL_pressed():
	$LoadWorld/worldSelects.get_child(page).hide()
	page -= 1
	$LoadWorld/worldSelects.get_child(page).show()
	update_buttons()

func _on_ArrowR_pressed():
	$LoadWorld/worldSelects.get_child(page).hide()
	page += 1
	$LoadWorld/worldSelects.get_child(page).show()
	update_buttons()

func _on_Delete_pressed():
	get_node("../../Click").play()
	globals.remove_recursive(savePath + worldPathSelected)
	worldPathSelected = null
	$LoadWorld/play.disabled = true
	$LoadWorld/Delete.disabled = true
	load_icons()

func _on_Ok_pressed():
	get_node("../../Click").play()
	globals.worldNamePath = worldPathSelected
	get_tree().change_scene("res://scene/Main.tscn")

func _on_WarnBack_pressed():
	get_node("../../Click").play()
	$LoadWorld/Warning.hide()
	$LoadWorld/Warning2.hide()
	$LoadWorld/Warning3.hide()
	worldPathSelected = null
	$LoadWorld/play.disabled = true
	$LoadWorld/Delete.disabled = true

func _on_Customize_pressed():
	$CustomizeWorld/Gamemode/Label.text = gamemodes[gamemodeTab]
	$CustomizeWorld/WorldType/Label.text = worldTypes[worldTypeTab]
	$NewWorld.hide()
	$CustomizeWorld.show()


func _on_CustomizeBack_pressed():
	$CustomizeWorld.hide()
	$NewWorld.show()

func _on_Gamemode_pressed():
	if gamemodeTab < gamemodes.size()-1:
		gamemodeTab += 1
	else:
		gamemodeTab = 0
	$CustomizeWorld/Gamemode/Label.text = gamemodes[gamemodeTab]

func _on_WorldType_pressed():
	if worldTypeTab < worldTypes.size()-1:
		worldTypeTab += 1
	else:
		worldTypeTab = 0
	$CustomizeWorld/WorldType/Label.text = worldTypes[worldTypeTab]

func _on_CreateTutorial_pressed():
	get_node("../../Click").play()
	globals.new_tutorial()
	get_tree().change_scene("res://scene/Main.tscn")
