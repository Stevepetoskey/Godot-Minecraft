extends CanvasLayer

func _process(delta):
	if Input.is_action_just_pressed("toggleDebug"):
		var show = !$Pos.visible
		$Pos.visible = show
		$FPS.visible = show
		$Label.visible = show
		$EC.visible = show
