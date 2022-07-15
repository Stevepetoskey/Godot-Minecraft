extends KinematicBody2D

const SPEED = 16
const GRAVITY = 9.8
const JUMPSPEED = 150

var maxSpeed = 64
var motion = Vector2(0,0)

const TYPE = "player"

var ready = false
var new = true
var health = 20
var inAir = false
var firstHeight = 0
var flyMode = false

var hunger = 20
var saturation = 5
var exhaustion = 0
var hungerEffect = false
var sprintdis = 0
var flip = 0
var onLadder = []
var inWater = []
var stairRight = []
var stairLeft = []
var stairRightBottom = []
var stairLeftBottom = []
var onStairs = false
var inMenu = false
onready var holding = get_node("body/RightArm/holding")

onready var hotbar = get_node("../CanvasLayer/hotbar")
onready var inventory = get_node("../CanvasLayer/Inventory")
onready var main = get_node("..")
onready var globals = get_node("/root/GlobalScript")

var playerLoadPos = Vector2(0,0)
var playerChunk = 0
var dead = false

func _physics_process(_delta):
	if ready and !inventory.visible and !dead:
		if Input.is_action_just_pressed("menu"):
			get_node("../CanvasLayer/Menu").visible = !inMenu
			inMenu = !inMenu
		if !inMenu:
			#Hunger handler
			if globals.gamemode != "Creative":
				if !hungerEffect:
					if hunger >= 18 and health<20:
						$hungerEffect.start(4)
						hungerEffect = true
					elif hunger == 20 and health <20 and saturation > 0:
						$hungerEffect.start(0.5)
						hungerEffect = true
				if exhaustion >= 4:
					saturation -= 1
					if saturation <= 0:
						hunger -= 1
					exhaustion -= 4
			get_node("../CanvasLayer/FPS").text = str(Engine.get_frames_per_second())
			get_node("../CanvasLayer/Pos").text = str(Vector2(round(position.x/16),round(position.y/16)))
			if Input.is_action_just_pressed("ui_down"):
				get_node("../Lighting")._on_Daylight_Cycle_timeout()
			if Input.is_action_just_pressed("save"):
				get_node("..").save_game()
			if holding == $body/RightArm/holding:
				$body/LeftArm/holding.hide()
			else:
				$body/RightArm/holding.hide()
			if inventory.inventory[get_node("../CanvasLayer/hotbar/select").selected]["id"] > 0:
				holding.show()
				holding.texture = hotbar.textures[inventory.inventory[get_node("../CanvasLayer/hotbar/select").selected]["id"]]
				if hotbar.itemData.has(inventory.inventory[get_node("../CanvasLayer/hotbar/select").selected]["id"]) or hotbar.itemDamage.has(inventory.inventory[get_node("../CanvasLayer/hotbar/select").selected]["id"]):
					holding.scale = Vector2(1,1)
					holding.position = Vector2(6*sign(-2*flip+1),8)
				else:
					holding.scale = Vector2(0.40,0.40)
					#yes
					holding.position = Vector2(4*sign(-2*flip+1),8)
			else:
				holding.hide()
			if floor($Camera2D.global_position.x/16/ main.chunkSize.x) != playerChunk:
				main.update_chunks(floor($Camera2D.global_position.x/16/ main.chunkSize.x))
				playerChunk = floor($Camera2D.global_position.x/16/ main.chunkSize.x)
			if abs(playerLoadPos.x - round($Camera2D.global_position.x / 16)) > 0 or abs(playerLoadPos.y - round(position.y / 16)) > 0: #Renders blocks if moved a certain distance
				playerLoadPos = Vector2(round($Camera2D.global_position.x / 16),round($Camera2D.global_position.y / 16))
				main.load_chunk(int(playerChunk))
			if get_global_mouse_position().x < global_position.x:
				$head.rotation = $head.global_position.angle_to_point(get_global_mouse_position()) #+ deg2rad(90)
			else:
				$head.rotation = $head.global_position.angle_to_point(get_global_mouse_position()) + deg2rad(180)
			flip_textures(get_global_mouse_position().x < global_position.x)
			if Input.is_action_pressed("sprint") and hunger > 6:
				maxSpeed = 128
			else:
				maxSpeed = 64
			if abs(motion.x) > 64:
				$AnimationPlayer.playback_speed = 3
			else:
				$AnimationPlayer.playback_speed = 1.5
			if Input.is_action_pressed("right") and motion.x < maxSpeed:
				motion.x += SPEED
				$AnimationPlayer.play("Walk")
			if Input.is_action_pressed("left") and motion.x > -maxSpeed:
				motion.x -= SPEED
				$AnimationPlayer.play("Walk")
			if !Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
				motion.x = move_toward(motion.x,0,SPEED)
				$AnimationPlayer.play("idle")
			if Input.is_action_just_pressed("fly") and globals.gamemode == "Creative":
				flyMode = !flyMode
			if Input.is_action_pressed("break"):
				if get_global_mouse_position().x < global_position.x:
					$breakAni.play("breakLeft")
				else:
					$breakAni.play("break")
			else:
				$breakAni.stop(true)
			if inWater == [] and onLadder == [] and !flyMode:
				if !is_on_floor():
					if motion.y < 400:
						motion.y += GRAVITY
					if !inAir:
						firstHeight = round(position.y/16.0)
					inAir = true
				else:
					var blockOn = main.block("get",Vector2(int(round(position.x/16)),int(round(position.y+32)/16)))
					#print(blockOn, ": ", Vector2(int(round(position.x/16)),int(round(position.y+32)/16)))
					motion.y = 0
					if inAir:
						if firstHeight - round(position.y/16.0) < -3:
							take_damage((firstHeight - round(position.y/16.0) + 3)*-1)
					if !$movement.playing and motion.x != 0 and ![0,41,60].has(blockOn):
						var soundFile = main.sound_data[main.block_data[blockOn].soundFiles].step
						$movement.stream = load("res://Audio/" + soundFile + str(randi()%int(main.sound_amount[soundFile])+1) + ".ogg")
						$movement.play()
						$walkEnd.start()
					inAir = false
				if Input.is_action_pressed("jump") and !inAir:
					if maxSpeed == 128:
						exhaustion += 0.2
					else:
						exhaustion += 0.05
					motion.y = -JUMPSPEED
				if is_on_wall() and !is_on_ceiling():
					if motion.x < 0 and stairLeft.empty() and !stairLeftBottom.empty():
						position.y -= 9
						onStairs = true
					elif motion.x > 0 and stairRight.empty() and !stairRightBottom.empty():
						position.y -= 9
						onStairs = true
			elif inWater != []:
				inAir = false
				if Input.is_action_pressed("jump"):
					motion.y = -JUMPSPEED/2
				else:
					motion.y = JUMPSPEED/2
			elif onLadder != []:
				inAir = false
				if Input.is_action_pressed("jump"):
					motion.y = -JUMPSPEED/2
				elif Input.is_action_pressed("sneak"):
					motion.y = 0
				else:
					motion.y = JUMPSPEED/2
			elif flyMode:
				inAir = false
				if Input.is_action_pressed("jump"):
					motion.y = -JUMPSPEED
				elif Input.is_action_pressed("sneak"):
					motion.y = JUMPSPEED
				else:
					motion.y = 0
			if is_on_wall():
				if !onStairs:
					motion.x = 0
				else:
					onStairs = false
			move_and_slide(motion,Vector2(0,-1))

func flip_textures(f):
	flip = int(f)
	holding = [$body/RightArm/holding,$body/LeftArm/holding][int(f)]
#	$body/RightArm/holding.visible = false
#	$body/LeftArm/holding.visible = false
	$head.flip_h = f
	$body.region_rect.position = Vector2(4,8+(12*int(f)))
	$body/RightArm.region_rect.position = Vector2(12,8+(12*int(f)))
	$body/LeftArm.region_rect.position = Vector2(16,8+(12*int(f)))
	$RightLeg.region_rect.position = Vector2(0,8+(12*int(f)))
	$LeftLeg.region_rect.position = Vector2(8,8+(12*int(f)))

func take_damage(dmg,knockback = false,dir = 0,power = 200):
	if globals.gamemode != "Creative":
		$hurt.play()
		health -= dmg
		if health <= 0:
			main.player_died()
			$CollisionShape2D.disabled = true
			dead = true
		if knockback:
			motion.x += power * dir
			motion.y -= power/1.5
		$head.modulate = Color(1,0.5,0.5)
		$body.modulate = Color(1,0.5,0.5)
		$body/RightArm.modulate = Color(1,0.5,0.5)
		$body/LeftArm.modulate = Color(1,0.5,0.5)
		$RightLeg.modulate = Color(1,0.5,0.5)
		$LeftLeg.modulate = Color(1,0.5,0.5)
		yield(get_tree().create_timer(0.25), "timeout")
		$head.modulate = Color(1,1,1)
		$body.modulate = Color(1,1,1)
		$body/RightArm.modulate = Color(1,1,1)
		$body/LeftArm.modulate = Color(1,1,1)
		$RightLeg.modulate = Color(1,1,1)
		$LeftLeg.modulate = Color(1,1,1)

func _on_hunger_timeout():
	exhaustion += 0.1
#	hunger -= hungerMultiplier*0
#	if hunger <= 0:
#		hunger = 600
#		get_node("../CanvasLayer/Bars/HungerBar").hunger -= 1

func _on_BlockTest_area_entered(area):
	if area.name == "BlockCollide":
		match area.get_node("..").id:
			54:
				onLadder.append(area)
			41:
				if area.get_node("..").z == 1:
					inWater.append(area)
			60:
				if area.get_node("..").z == 1 and main.interactableBlockData[[area.get_node("..").pos,1]][0] > 6:
					inWater.append(area)

func _on_BlockTest_area_exited(area):
	if area.name == "BlockCollide":
		match area.get_node("..").id:
			54:
				onLadder.erase(area)
			41,60:
				inWater.erase(area)

func _on_Node2D_start():
	if new:
		go_to_spawn()
		new = false
		get_node("../Lighting").playerLoaded = true

func go_to_spawn():
	var x = 0
	var breakout = true
	while breakout:
		for y in range(128):
			if main.block("get",Vector2(x,y)) > 0 and main.block("get",Vector2(x,y-1)) == 0 and main.block("get",Vector2(x,y-2)) == 0:
				position = Vector2(x,y-4) * Vector2(16,16)
				breakout = false
				break
		if x < 0:
			x*=-1
		elif x > 0:
			x = x*-1 - 1
		else:
			x = -1

func _on_Hunger_timeout():
	if hunger >= 18 and health<20:
		health += 1
		exhaustion += 6
	elif hunger == 20 and health<20 and saturation > 0:
		health += 1
		exhaustion += 6
	if hunger == 0 and health > 1:
		health -= 1
	hungerEffect = false

func _on_Sprint_timeout():
	if motion.x > 64:
		exhaustion += 0.1

func _on_Node2D_world_loaded():
	get_node("../CanvasLayer/Loading").visible = false
	ready = true

func _on_walkEnd_timeout():
	$movement.stop()

func _on_stairTest_body_entered(body):
	if body != self and body.is_in_group("block"):
		stairRight.append(body)

func _on_stairTestRight_body_exited(body):
	if body != self and body.is_in_group("block"):
		stairRight.erase(body)

func _on_stairTestLeft_body_entered(body):
	if body != self and body.is_in_group("block"):
		stairLeft.append(body)

func _on_stairTestLeft_body_exited(body):
	if body != self and body.is_in_group("block"):
		stairLeft.erase(body)

func _on_stairTestRight2_body_entered(body):
	if body != self and body.is_in_group("block"):
		stairRightBottom.append(body)

func _on_stairTestRight2_body_exited(body):
	if body != self and body.is_in_group("block"):
		stairRightBottom.erase(body)

func _on_stairTestLeft2_body_entered(body):
	if body != self and body.is_in_group("block"):
		stairLeftBottom.append(body)

func _on_stairTestLeft2_body_exited(body):
	if body != self and body.is_in_group("block"):
		stairLeftBottom.erase(body)
