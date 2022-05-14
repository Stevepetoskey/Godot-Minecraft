extends Sprite

var keys = {KEY_1:0,KEY_2:1,KEY_3:2,KEY_4:3,KEY_5:4,KEY_6:5,KEY_7:6,KEY_8:7,KEY_9:8}
var selected = 0

func _input(ev):
	if ev is InputEventKey and keys.has(ev.scancode):
		var key = keys[ev.scancode]
		position.x = (key-4)*20
		selected = key
		get_node("../../../cursor").stage = -1
