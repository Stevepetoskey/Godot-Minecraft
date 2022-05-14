extends TextureRect

var smeltable = {6:15,7:24,13:3,42:43,3:51,47:49,55:56}
var fuel = {25:800,15:80,4:15,8:15,10:15,11:10,12:10,14:10,16:10,9:5}

func noZero(val):
	if val == 0:
		return 1
	return val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible and get_node("../Inventory").currentFurnace[3] > 0:
		$progress.value = get_node("../Inventory").currentFurnace[2]
		print(get_node("../Inventory").currentFurnace[3], " , ",float(get_node("../Inventory").currentFurnace[4]), " , ",get_node("../Inventory").currentFurnace[3]/float(noZero(get_node("../Inventory").currentFurnace[2]))/14)
		$fire.value = (get_node("../Inventory").currentFurnace[3]/float(noZero(get_node("../Inventory").currentFurnace[2])))/14
	else:
		$progress.value = 0
		$fire.value = 0
