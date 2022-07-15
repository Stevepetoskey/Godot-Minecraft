extends KinematicBody2D

const GRAVITY = 9.8
const TYPE = "item"

var motion = Vector2(0,0)

var itemID = 0
var itemNum = 0
var collectable = true

func _ready():
	if !collectable:
		$Timer.start()

func _physics_process(delta):
	if is_on_floor():
		motion.y = 0
		motion.x = move_toward(motion.x,0,16)
		collectable = true
	else:
		motion.y += GRAVITY
	move_and_slide(motion,Vector2(0,-1))

func _on_Area2D_body_entered(body):
	if body != self:
		if body.name == "Item":
			if body.itemID == itemID:
				if body.itemNum + itemNum > 64:
					body.itemNum = 64
					itemNum = itemNum + body.itemNum - 64
				else:
					body.itemNum += itemNum
					itemNum = 0
					queue_free()
		elif body.name == "Player" and collectable:
			for i in range(25):
				position = lerp(position,body.position,i/75.0)
				yield(get_tree().create_timer(0.01), "timeout")
			get_node("../../CanvasLayer/hotbar").add_to_inventory(itemID,itemNum)
			itemNum = 0
			queue_free()

func _on_Timer_timeout():
	collectable = true
