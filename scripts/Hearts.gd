extends Node2D

func _ready():
	for i in range(0,20,2):
		var heart = load("res://assets/Heart.tscn").instance()
		heart.health = i
		heart.position = Vector2(i*4.5,0)
		add_child(heart)
