extends Spatial

const ATSHADER = preload("res://assets/Sky/Planet.tres")

export var rotationSpeed = 0.1
export var rotationMultiplier = 1.0
export var orbitSpeed : float = 1
export var orbitMultiplier = 0.1
export var distance = 1
export var hasAtmoshpere = true
export var mainPlanet = false
export var orbit = 0.0
export var orbitingBody = "Sun"
export var planetMaterial : Material
export var atmosphereSize = 1.1
export var atmosphereDes = 0.25
export var atmosphereColor = Color(0.47,0.8,1)
#export var tilt = 0

onready var main = get_node("..")

# Called when the node enters the scene tree for the first time.
func _ready():
	$MeshInstance2.mesh = ATSHADER.duplicate(true)
	$MeshInstance2.mesh.radius = atmosphereSize
	$MeshInstance2.mesh.height = atmosphereSize*2.0
	if planetMaterial != null:
		$MeshInstance.material_override = planetMaterial
#	$MeshInstance.rotation.z = deg2rad(tilt)
	translation = Vector3(cos(deg2rad(orbit))*distance,0,sin(deg2rad(orbit))*distance)
	if hasAtmoshpere:
		$SpotLight.rotation.y = deg2rad(orbit+90)
	else:
		$SpotLight.hide()
		$MeshInstance2.hide()
	if mainPlanet:
		$MeshInstance/Camera.current = true
		if hasAtmoshpere:
			$SpotLight.visible = true
			$MeshInstance2.mesh.flip_faces = true
			$MeshInstance2.layers = 2
	$MeshInstance2.get_surface_material(0).albedo_color = Color(atmosphereColor.r,atmosphereColor.g,atmosphereColor.b,atmosphereDes)
	$Rotate.start(rotationSpeed)
	$Orbit.start(orbitSpeed)

func _process(delta):
	if Input.is_action_pressed("view_left"):
		$MeshInstance/Camera.rotation_degrees.x -= 1
	if Input.is_action_pressed("view_right"):
		$MeshInstance/Camera.rotation_degrees.x += 1

func _on_Timer_timeout():
	if rad2deg($MeshInstance.rotation.y) < 360:
		$MeshInstance.rotation.y += deg2rad(rotationMultiplier)
	else:
		$MeshInstance.rotation.y = deg2rad(0)

func _on_Orbit_timeout():
	if orbit < 360:
		orbit += orbitMultiplier
	else:
		orbit = 0
	translation = Vector3(cos(deg2rad(orbit))*distance,0,sin(deg2rad(orbit))*distance) + main.get_node(orbitingBody).translation
	if hasAtmoshpere:
		$SpotLight.look_at(main.get_node(orbitingBody).translation,Vector3(0,1,0))
