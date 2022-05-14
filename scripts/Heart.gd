extends Sprite

var health = 0

func _process(delta):
	var playerHealth = get_node("../../../../Player").health
	if playerHealth == health+1:
		$HeartFull.region_rect = Rect2(Vector2(62,1),Vector2(4,7))
		$HeartFull.position.x = -1.5
		$HeartFull.visible = true
	elif playerHealth < health+1:
		$HeartFull.visible = false
	else:
		$HeartFull.region_rect = Rect2(Vector2(53,1),Vector2(7,7))
		$HeartFull.position.x = 0
		$HeartFull.visible = true
		
