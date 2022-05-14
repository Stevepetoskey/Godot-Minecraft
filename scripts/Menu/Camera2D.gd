extends Camera2D

func _physics_process(delta):
	position.x += 4
	position.y = sin(position.x/100.0)*50
