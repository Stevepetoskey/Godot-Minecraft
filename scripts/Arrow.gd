extends KinematicBody2D

const GRAVITY = 9.8
const TYPE = "arrow"

onready var main = get_node("../..")

var dmg = 1
var motion = Vector2(0,0)
var landed = false
var friendly = false
var shotFrom = null

func _physics_process(delta):
	if !is_on_floor():
		motion.y += GRAVITY
		motion.x *= 0.999
		move_and_slide(motion,Vector2(0,-1))
		landed = false
	elif !landed:
		landed = true
		motion = Vector2(0,0)
		$Timer.start()
#	if motion.x < 0:
#		$Sprite.flip_h = true
#	elif motion.x > 0:
#		$Sprite.flip_h = false
	if !landed:
		rotation = Vector2(0,0).angle_to_point(motion)

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_area_entered(area):
	var body = area.get_node("..")
	if !landed and body != shotFrom:
		body.take_damage(dmg,true,sign(motion.x))
		queue_free()
	elif body.TYPE == "player" and friendly:
		get_node("../../CanvasLayer/hotbar").add_to_inventory(61,1)
		queue_free()
