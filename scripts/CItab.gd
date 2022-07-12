extends TextureButton

export var tab : String

onready var creativeInventory = get_node("..")

func _ready():
	$Sprite.texture = get_node("../../../hotbar").textures[creativeInventory.tabs[tab]["icon"]]

func _on_CItab_pressed():
	creativeInventory.tab_pressed(tab)
