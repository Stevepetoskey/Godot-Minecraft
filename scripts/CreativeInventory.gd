extends Sprite

var tabs = {
	"Building Blocks":{"items":[1,2,3,4,6,7,27,72,77,82,8,13,25,26,73,79,28,35,42,43,44,45,48,50,51,52,64,65,68,69,97,98],"icon":50},
	"Decoration Blocks":{"items":[5,10,23,53,54,57,58,66,67,70,71],"icon":57},
	"Redstone":{"items":[83,84,62,80],"icon":83},
	"Transportation":{"items":[],"icon":43},
	"Miscellaneous":{"items":[9,15,24,75,78,34,76,41,59,46,47,74],"icon":41},
	"Foodstuffs":{"items":[55,56,81],"icon":81},
	"Tools":{"items":[11,12,14,17,85,86,87,89,18,19,20,22,29,30,31,33,36,37,38,40],"icon":30},
	"Combat":{"items":[16,88,21,32,39,61],"icon":88},
#	"Brewing":{"items":[],"icon":43},
	}
var currentTab = "Building Blocks"

onready var globals = get_node("/root/GlobalScript")

# Called when the node enters the scene tree for the first time.

func _ready():
	tab_pressed($CItab)
	for loc in range(9):
		var icon = load("res://assets/inventoryIcon.tscn").instance()
		icon.loc = loc
		icon.rect_position = Vector2(loc*18-88,45)
		icon.main =get_node("../Inventory")
		icon.type = "inventory"
		$invIcons.add_child(icon)

func tab_pressed(tab):
	for child in get_children():
		if child.get_class() == "TextureButton":
			child.pressed = false
			child.show_behind_parent = true
	tab.pressed = true
	tab.show_behind_parent = false
	currentTab = tab.tab
	load_items()

func load_items():
	for child in $icons.get_children():
		child.queue_free()
	var pos = Vector2(-120,-115)
	for item in tabs[currentTab]["items"]:
		var icon = load("res://assets/CreativeIcon.tscn").instance()
		icon.rect_position = pos
		icon.id = item
		icon.texture_normal = get_node("../hotbar").textures[item]
		if pos.x < 24:
			pos.x += 18
		else:
			pos.x = -120
			pos.y += 18
		$icons.add_child(icon)
