extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$CanvasLayer/Ver.text = "Version: " + get_node("/root/GlobalScript").CURRENTVER
	$AudioStreamPlayer.stream = load("res://Music/Menu ("+ str(randi()%4+1) + ").ogg")
	$AudioStreamPlayer.play()

func _on_Exit_pressed():
	$Click.play()
	yield($Click,"finished")
	get_tree().quit()

func _on_Play_pressed():
	$Click.play()
	$CanvasLayer/MainScreen.hide()
	$CanvasLayer/WorldSelect.worldPathSelected = null
	$CanvasLayer/WorldSelect.load_icons()
	$CanvasLayer/WorldSelect.show()

func _on_Back_pressed():
	$Click.play()
	$CanvasLayer/WorldSelect.hide()
	$CanvasLayer/WorldSelect/LoadWorld/Warning.hide()
	$CanvasLayer/WorldSelect/LoadWorld/Warning2.hide()
	$CanvasLayer/WorldSelect/LoadWorld/Warning3.hide()
	$CanvasLayer/MainScreen.visible = true


func _on_AudioStreamPlayer_finished():
	$NextSong.start(rand_range(30,240))

func _on_NextSong_timeout():
	$AudioStreamPlayer.stream = load("res://Music/Menu ("+ str(randi()%4+1) + ").ogg")
	$AudioStreamPlayer.play()
