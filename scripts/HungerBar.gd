extends Node2D

func _ready():
	for i in range(0,20,2):
		var meat = load("res://assets/Hunger.tscn").instance()
		meat.hunger = i
		meat.position = Vector2(-i*4.5,0)
		add_child(meat)
