extends StaticBody2D

const MAX_LEVEL = 8

var id = 0
var z = 1

var gone = false

onready var main = get_node("../../..")
onready var pos = global_position/ Vector2(16,16)

func _ready():
	if z == 0:
		z_index = -1
	if main.interactableBlockData.has([pos,z]):
		var currentLevel = main.interactableBlockData[[pos,z]][0]
		$Sprite.material.set_shader_param("value",currentLevel/8.0)

func _on_Spread_timeout():
	var currentLevel = MAX_LEVEL
	if id == 60:
		currentLevel = main.interactableBlockData[[pos,z]][0]
	$Sprite.material.set_shader_param("value",currentLevel/8.0)
	var bottomBlock = main.block("get",pos + Vector2(0,1),z)
	var leftBlock = main.block("get",pos - Vector2(1,0),z)
	var rightBlock = main.block("get",pos + Vector2(1,0),z)
	var topBlock = main.block("get",pos - Vector2(0,1),z)
	var spreadBellow = false
	#Spreading bellow
	if bottomBlock == 0 or main.block_data[bottomBlock].waterBreaks:
		if main.block_data[bottomBlock].waterBreaks:
			main.build_event("break",pos + Vector2(0,1),0,z)
		main.build_event("build",pos + Vector2(0,1),60,z,false,{"level":MAX_LEVEL})
		spreadBellow = true
	elif bottomBlock == 60 and main.interactableBlockData[[pos + Vector2(0,1),z]][0] < MAX_LEVEL:
		main.interactableBlockData[[pos + Vector2(0,1),z]][0] = MAX_LEVEL
	if (![60,41].has(bottomBlock) or id == 41) and !spreadBellow and currentLevel > 1:
		#spreading left
		if (leftBlock == 0 or main.block_data[leftBlock].waterBreaks):
			if main.block_data[leftBlock].waterBreaks:
				main.build_event("break",pos - Vector2(1,0),0,z)
			main.build_event("build",pos - Vector2(1,0),60,z,false,{"level":currentLevel -1})
		elif leftBlock == 60 and main.interactableBlockData[[pos - Vector2(1,0),z]][0] < currentLevel - 1:
			main.interactableBlockData[[pos - Vector2(1,0),z]][0] = currentLevel - 1
		#spreading right
		if (rightBlock == 0 or main.block_data[rightBlock].waterBreaks):
			if main.block_data[rightBlock].waterBreaks:
				main.build_event("break",pos + Vector2(1,0),0,z)
			main.build_event("build",pos + Vector2(1,0),60,z,false,{"level":currentLevel -1})
		elif rightBlock == 60 and main.interactableBlockData[[pos + Vector2(1,0),z]][0] < currentLevel - 1:
			main.interactableBlockData[[pos + Vector2(1,0),z]][0] = currentLevel - 1
	if id != 41 and (![60,41].has(leftBlock) or main.interactableBlockData[[pos - Vector2(1,0),z]][0] <= currentLevel) and (![60,41].has(rightBlock) or main.interactableBlockData[[pos + Vector2(1,0),z]][0] <= currentLevel) and ![60,41].has(topBlock):
		if [60,41].has(bottomBlock):
			main.interactableBlockData[[pos,z]][0] -= 1
		main.interactableBlockData[[pos,z]][0] -= 1
		if main.interactableBlockData[[pos,z]][0] <= 0:
			main.build_event("break",pos,0,z,false)
