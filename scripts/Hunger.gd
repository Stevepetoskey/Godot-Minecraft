extends Sprite

var hunger = 0

func _process(delta):
	var playerHunger = get_node("../../../../Player").hunger
	if playerHunger == hunger+1:
		$HungerFull.region_rect = Rect2(Vector2(63,28),Vector2(6,7))
		$HungerFull.position.x = .5
		$HungerFull.visible = true
	elif playerHunger < hunger+1:
		$HungerFull.visible = false
	else:
		$HungerFull.region_rect = Rect2(Vector2(53,28),Vector2(7,7))
		$HungerFull.position.x = 0
		$HungerFull.visible = true
		

