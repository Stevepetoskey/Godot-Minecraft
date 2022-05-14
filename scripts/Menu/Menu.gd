extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Exit_pressed():
	get_tree().quit()

func _on_Play_pressed():
	$CanvasLayer/MainScreen.visible = false
	$CanvasLayer/WorldSelect.worldPathSelected = null
	$CanvasLayer/WorldSelect.load_icons()
	$CanvasLayer/WorldSelect.visible = true

func _on_Back_pressed():
	$CanvasLayer/WorldSelect.visible = false
	$CanvasLayer/MainScreen.visible = true
