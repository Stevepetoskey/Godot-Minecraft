extends Node2D

var text = ["Now with 0 original ideas!","First free pro game!","No microtransactions! yet","'Suprise game mechanics' are in the work!","Hosted on freegamesnovirus.io!","Stealing data is immoral, not illegal!","Now with a subscription model!","Buy the nether DLC!","Give me your money!",">Insert product placement here<","Still learning the Amungos SMP lore!"]
var scaleDown = false

func _process(delta):
	if $CanvasLayer/MainScreen/BonusText.rect_scale.x < 1 and !scaleDown:
		$CanvasLayer/MainScreen/BonusText.rect_scale += Vector2(delta/2,delta/2)
	else:
		scaleDown = true
		$CanvasLayer/MainScreen/BonusText.rect_scale -= Vector2(delta/2,delta/2)
		if $CanvasLayer/MainScreen/BonusText.rect_scale.x <= 0.75:
			scaleDown = false
	$Background.position.x -= delta*10
	print($Background.position)
	if $Background.position.x <= -1862:
		$Background.position.x = 3784

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	text.shuffle()
	$CanvasLayer/MainScreen/BonusText.text = text[0]
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
	text.shuffle()
	$CanvasLayer/MainScreen/BonusText.text = text[0]
	$CanvasLayer/MainScreen.visible = true


func _on_AudioStreamPlayer_finished():
	$NextSong.start(rand_range(30,240))

func _on_NextSong_timeout():
	$AudioStreamPlayer.stream = load("res://Music/Menu ("+ str(randi()%4+1) + ").ogg")
	$AudioStreamPlayer.play()
