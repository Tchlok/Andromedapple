class_name Orbit
extends Node2D

const orbitCirclePath : String = "res://Scenes/OrbitCircle.tscn"
@export var clockwise : bool = true
@export var cycleDuration : float = 10
var cycleT : float

@export var satellites : Array[Node2D]
var satelliteOffsets : Array[Vector2]


func _enter_tree():
	var temp : Array[Node2D] = satellites.duplicate()
	satellites.clear()
	for s in temp:
		addSatellite(s)
func addSatellite(child : Node2D):
	if satellites.has(child):
		return
	satellites.append(child)
	satelliteOffsets.append(global_position-child.global_position)
	var circ : DrawCircle = load(orbitCirclePath).instantiate()
	circ.Radius(global_position.distance_to(child.global_position))
	add_child(circ)

func _physics_process(delta):
	cycleT+=delta
	if cycleT>cycleDuration:
		cycleT-=cycleDuration
	var rad
	if clockwise:
		rad=deg_to_rad((cycleT/cycleDuration)*360)
	else:
		rad=deg_to_rad((1-(cycleT/cycleDuration))*360)

	for i in range(satellites.size()):
		satellites[i].position=position+satelliteOffsets[i].rotated(rad)
