extends Sprite

var tabs = {
	"Building Blocks":{"items":[1,2,3,4,6,7,8,13,25,26,27,28,35,42,43,44,45,48,50,51,52,64,65,68,69],"icon":50},
	"Decoration Blocks":{"items":[5,10,23,53,54,57,58,66,67,70,71],"icon":57},
	"Redstone":{"items":[62],"icon":62},
	"Transportation":{"items":[],"icon":43},
	"Miscellaneous":{"items":[9,15,24,34,41,59,46,47],"icon":41},
	"Foodstuffs":{"items":[55,56],"icon":56},
	"Tools":{"items":[11,12,14,17,18,19,20,22,29,30,31,33,36,37,38,40],"icon":30},
	"Combat":{"items":[16,21,32,39,61],"icon":61},
	"Brewing":{"items":[],"icon":43},
	}
var currentTab = "Building Blocks"

onready var globals = get_node("/root/GlobalScript")

# Called when the node enters the scene tree for the first time.
func _ready():
	if globals.gamemode == "Creative":
		load_inventory()

func load_inventory():
	for tab in tabs:
		var tabHolder = Node2D.new()
		tabHolder.name = tab
		$tabs.add_child(tabHolder)
		for item in range(tabs[tab]["items"]):
			pass

func tab_pressed(tab):
	pass
