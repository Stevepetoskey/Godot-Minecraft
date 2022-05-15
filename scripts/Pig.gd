extends KinematicBody2D

const SPEED = 16
const GRAVITY = 9.8
const JUMPSPEED = 150 #normal 150
const TYPE = "pig"

onready var main = get_node("../..")

var xMotion = 0
var health = 20
var motion = Vector2(0,0)
var walking = false
var loaded = true
var mouseIn = false

var soundWait = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	main.connect("update",self,"on_update")

func is_block_loaded(pos):
	if main.chunks[main.get_chunk(pos.x)][1][main.chunkifyI(pos.x)][pos.y] > 0:
		if get_node("../../chunks").has_node(str(main.get_chunk(pos.x)) + "/1,"+str(main.chunkifyI(pos.x))+","+str(pos.y)):
			return true
		else:
			return false
	else:
		return true

func _physics_process(delta):
	if Input.is_action_just_pressed("break") and mouseIn and position.distance_to(get_node("../../Player").position) <= 64:
		get_node("../../Player").exhaustion += 0.1
		take_damage(get_node("..").get_damage(),true,sign(position.x - get_node("../../Player").position.x))
	if health <= 0 and !$death.playing:
		if !$death.playing:
			print("guh")
			$death.play()
		yield($death,"finished")
		get_node("..").add_item(55,randi()%3+1,position,false)
		queue_free()
	if loaded:
		if !is_on_floor():
			if motion.y < 400:
				motion.y += GRAVITY
		else:
			motion.y = 0
		if is_on_wall() and is_on_floor():
			motion.y -= JUMPSPEED
		if abs(xMotion) > 0:
			if !soundWait:
				$walk.stream = load("res://Audio/mob/pig/step" + str(randi()%5+1) +".ogg")
				$walk.play()
				soundWait = true
				$walkEnd.start()
			$AnimationPlayer.play("Walk")
			if xMotion > 0:
				$Head.flip_h = true
				$Head.offset = Vector2(4,0)
				$Head.position = Vector2(6.5,-2)
				$Body.flip_v = false
				$FRLeg.flip_h = true
				$FLLeg.flip_h = true
				$BLLeg.flip_h = true
				$BRLeg.flip_h = true
			else:
				$Head.flip_h = false
				$Head.offset = Vector2(-4,0)
				$Head.position = Vector2(-6.5,-2)
				$Body.flip_v = true
				$FRLeg.flip_h = false
				$FLLeg.flip_h = false
				$BLLeg.flip_h = false
				$BRLeg.flip_h = false
		else:
			$AnimationPlayer.play("Idle")
		if !walking and randi()%50 == 0:
			xMotion = SPEED * (randi()%3-1)
			walking = true
			$Timer.start(rand_range(0,5))
		motion.x = move_toward(motion.x,xMotion,5)
		var blockPos = Vector2(round(position.x / 16),round(position.y / 16))
		if is_block_loaded(blockPos + Vector2(0,1)) and is_block_loaded(blockPos + Vector2(0,2)):
			move_and_slide(motion,Vector2(0,-1))
		else:
			loaded = false
			visible = false
		if randi()%100 == 1:
			$AudioStreamPlayer2D.stream = load("res://Audio/mob/pig/say" + str(randi()%3+1) + ".ogg")

func take_damage(dmg,knockback = false,dir = 0,power = 100):
	health -= dmg #get_node("..").get_damage()
	if knockback:
		motion.x += power * dir# * sign(position.x - get_node("../../Player").position.x) #normal 150
		motion.y -= power/1.5
	$Head.modulate = Color(1,0.5,0.5)
	$Body.modulate = Color(1,0.5,0.5)
	$FLLeg.modulate = Color(1,0.5,0.5)
	$FRLeg.modulate = Color(1,0.5,0.5)
	$BLLeg.modulate = Color(1,0.5,0.5)
	$BRLeg.modulate = Color(1,0.5,0.5)
	yield(get_tree().create_timer(0.25), "timeout")
	$Head.modulate = Color(1,1,1)
	$Body.modulate = Color(1,1,1)
	$FLLeg.modulate = Color(1,1,1)
	$FRLeg.modulate = Color(1,1,1)
	$BLLeg.modulate = Color(1,1,1)
	$BRLeg.modulate = Color(1,1,1)

func on_update():
	if !loaded:
		var blockPos = Vector2(round(position.x / 16),round(position.y / 16))
		if is_block_loaded(blockPos + Vector2(0,1)) and is_block_loaded(blockPos + Vector2(0,2)):
			loaded = true
			visible = true

func _on_Timer_timeout():
	walking = false
	xMotion = 0

func _on_hitbox_mouse_entered():
	mouseIn = true

func _on_hitbox_mouse_exited():
	mouseIn = false

func _on_walkEnd_timeout():
	soundWait = false
