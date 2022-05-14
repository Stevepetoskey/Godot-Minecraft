extends StaticBody2D

var id = 0
var z = 1

onready var main = get_node("../../..")
onready var pos = global_position/ Vector2(16,16)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../../../water").connect("waterUpdate",self,"on_water_update")
	main.connect("update",self,"on_update")
	on_water_update()

func on_water_update():
	for child in get_node("..").get_children():
		if child.name == name and child != self:
			print(name)
	if get_node("../../../water").water.has([pos,z]):
		$Sprite.material.set_shader_param("value",get_node("../../../water").water[[global_position/ Vector2(16,16),z]]/8.0)

func on_update():
	if id != 0 and main.block("get",pos,z) != id:
		queue_free()
