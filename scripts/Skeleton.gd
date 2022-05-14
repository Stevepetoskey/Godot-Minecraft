extends KinematicBody2D

const SPEED = 16
const GRAVITY = 9.8
const JUMPSPEED = 150 #normal 150
const TYPE = "skeleton"

onready var main = get_node("../..")

var xMotion = 0
var health = 20
var motion = Vector2(0,0)
var walking = false
var loaded = true
var mouseIn = false
var hittingPlayer = false
var shooting = false

var seePlayer = false
var lost = false
var playerPos : Vector2

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
	if loaded:
		#Sends raycast to see if can see the player
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position - Vector2(0,6), get_node("../../Player").global_position, [self,get_node("../../Player")])
		if abs(position.distance_to(get_node("../../Player").position)/16) > 10:
			result = []
		if result.size() == 0:
			$See.stop()
			lost = false
			seePlayer = true
			playerPos = get_node("../../Player").global_position
		if seePlayer:
			if result.size() > 0 and !lost:
				lost = true
				$See.start()
			if !lost and !shooting:
				shooting = true
				xMotion = 0
				$RightArm/Bow.play("shoot")
				yield($RightArm/Bow,"animation_finished")
				$RightArm/Bow.play("default")
				var arrow = load("res://assets/Arrow.tscn").instance()
				arrow.dmg = ceil(rand_range(3,5))
				var playerPos = get_node("../../Player").position
				var angle = position.angle_to_point(playerPos) + deg2rad(180)
				arrow.motion = Vector2(cos(angle)*(position.distance_to(playerPos)/10)*50,sin(angle)*(position.distance_to(playerPos)/10)*50)
				arrow.position = $RightArm/Bow.global_position
				arrow.shotFrom = self
				get_node("..").add_child(arrow)
				shooting = false
			elif lost:
				xMotion = SPEED * ((int(global_position.x<playerPos.x)-1)*2+1)
#			flip(global_position.x<playerPos.x)
			seePlayer = true
			$Head.rotation = $Head.global_position.angle_to_point(playerPos) + deg2rad(180) * int(global_position.x<playerPos.x)
		else:
			$Head.rotation = 0
		#damage handler
		if $AnimationPlayer.current_animation != "shooting":
			$RightArm/Bow.flip_h = true
			$RightArm/Bow.flip_h = false
		if Input.is_action_just_pressed("break") and mouseIn and abs(position.distance_to(get_node("../../Player").position)) <= 64:
			get_node("../../Player").exhaustion += 0.1
			take_damage(get_node("..").get_damage(),true,sign(position.x - get_node("../../Player").position.x))
		if health <= 0:
#			get_node("..").add_item(randi()%54+1,randi()%3+1,position,false)
			queue_free()
		#gravity
		if !is_on_floor():
			if motion.y < 400:
				motion.y += GRAVITY
		else:
			motion.y = 0
		if is_on_wall() and is_on_floor():
			motion.y -= JUMPSPEED
		#random motion
		if !seePlayer:
			if !walking and randi()%50 == 0:
				xMotion = SPEED * (randi()%3-1)
				walking = true
				$Timer.start(rand_range(0,5))
		#animation
		if abs(xMotion) > 0:
			if xMotion > 0:
				$AnimationPlayer.play("walk")
				flip(false)
			else:
				$AnimationPlayer.play("walkLeft")
				flip	(true)
		else:
			$AnimationPlayer.play("idle")
		#final motion/loading handler
		motion.x = move_toward(motion.x,xMotion,5)
		var blockPos = Vector2(round(position.x / 16),round(position.y / 16))
		if is_block_loaded(blockPos + Vector2(0,1)) and is_block_loaded(blockPos + Vector2(0,2)):
			move_and_slide(motion,Vector2(0,-1))
		else:
			loaded = false
			visible = false

func flip(f):
#	holding = [$body/RightArm/holding,$body/LeftArm/holding][int(f)]
#	$body/RightArm/holding.visible = false
#	$body/LeftArm/holding.visible = false
	$Head.flip_h = f
	$Body.flip_h = f
	$RightArm.flip_v = f
	if f:
		$RightArm.offset.y = -4
		$LeftArm.offset.y = -4
		if $AnimationPlayer.current_animation == "shooting":
			$RightArm/Bow.flip_h = false
			$RightArm/Bow.flip_h = true
	else:
		if $AnimationPlayer.current_animation == "shooting":
			$RightArm/Bow.flip_h = true
			$RightArm/Bow.flip_h = false
		$RightArm.offset.y = 4
		$LeftArm.offset.y = 4
	$LeftArm.flip_v = f
	$RightLeg.flip_h = f
	$LeftLeg.flip_h = f

func take_damage(dmg,knockback = false,dir = 0,power = 200):
	health -= dmg #get_node("..").get_damage()
	if knockback:
		motion.x += power * dir# * sign(position.x - get_node("../../Player").position.x) #normal 150
		motion.y -= power/1.5
	$Head.modulate = Color(1,0.5,0.5)
	$Body.modulate = Color(1,0.5,0.5)
	$RightArm.modulate = Color(1,0.5,0.5)
	$LeftArm.modulate = Color(1,0.5,0.5)
	$RightLeg.modulate = Color(1,0.5,0.5)
	$LeftLeg.modulate = Color(1,0.5,0.5)
	yield(get_tree().create_timer(0.25), "timeout")
	$Head.modulate = Color(1,1,1)
	$Body.modulate = Color(1,1,1)
	$RightArm.modulate = Color(1,1,1)
	$LeftArm.modulate = Color(1,1,1)
	$RightLeg.modulate = Color(1,1,1)
	$LeftLeg.modulate = Color(1,1,1)

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

func _on_See_timeout():
	seePlayer = false

func _on_Bow_timeout():
	pass # Replace with function body.
