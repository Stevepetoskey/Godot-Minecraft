extends TextureRect

var smeltable = {6:15,7:24,13:3,42:43,3:51,47:49,55:56,4:74,64:74,68:74,72:75,77:78}
var fuel = {25:800,15:80,4:15,8:15,10:15,11:10,12:10,14:10,16:10,9:5,74:80,64:15,68:15,57:5,71:5,67:5,65:15,62:10,69:15}

func noZero(val):
	if val == 0:
		return 1
	return val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible and get_node("../Inventory").currentFurnace[4] > 0:
		$progress.value = get_node("../Inventory").currentFurnace[3]
		$fire.value = (get_node("../Inventory").currentFurnace[4]/float(get_node("../Inventory").currentFurnace[5]))*14
	else:
		$progress.value = 0
		$fire.value = 0
