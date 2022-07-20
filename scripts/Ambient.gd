extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	stream = load("res://Music/Amb (" + str(randi()%13+1)+ ").ogg")
	play()
	$Timer.start(rand_range(120,700)) #normal 300, 700

func _on_Timer_timeout():
	if !playing:
		stream = load("res://Music/Amb (" + str(randi()%13+1)+ ").ogg")
		play()
	$Timer.start(rand_range(120,700))
