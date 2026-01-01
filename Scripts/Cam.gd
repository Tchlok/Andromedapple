class_name Cam
extends Node2D

@export var game : Game
@export var level : Level
@export var camera : Camera2D

var _zoomT : float
@export var stepZoom : float
@export var minZoom : float
@export var maxZoom : float
@export var defaultZoom : float
@export var speedZoom : float


@export var speedMove : float

func _ready():
	setZoomT(defaultZoom, true)

func setZoomT(newT : float, instant : bool = false):
	newT=MathS.Clamp01(newT)
	_zoomT=newT
	if instant:
		camera.zoom=Vector2.ONE*lerp(minZoom,maxZoom,pow(_zoomT,1.5))

var targetPosition : Vector2
var mousePosPrev : Vector2
var mouseDelta : Vector2
func _process(delta):
	mouseDelta=mousePosPrev-get_local_mouse_position()
	
	var target=lerp(minZoom,maxZoom,pow(_zoomT,1.5))

	if camera.zoom.x!=target:
		camera.zoom.x+=(target-camera.zoom.x)*delta*speedZoom
		if abs(camera.zoom.x-target)<0.005:
			camera.zoom.x=target
		camera.zoom.y=camera.zoom.x

	var targetRel : Vector2
	if relativeTo==null:
		targetRel=targetPosition
	else:
		targetRel=targetPosition+relativeTo.position

	if position!=targetRel:
		position+=(targetRel-position)*delta*speedMove
		if (position-targetRel).length()<2:
			position=targetRel

	mousePosPrev = get_local_mouse_position()
	if relativeTo!=null:
		position+=relativeTo.position-relativeToPosPrev
		relativeToPosPrev=relativeTo.position


func stepZoomIn():
	setZoomT(_zoomT+stepZoom)
func stepZoomOut():
	setZoomT(_zoomT-stepZoom)
func fullZoomIn():
	setZoomT(maxZoom)


func executePanMovement():
	targetPosition+=mouseDelta

func distanceToTarget():
	var relativeOffset = Vector2.ZERO
	if relativeTo!=null:
		relativeOffset=relativeTo.position
	return position.distance_to(targetPosition+relativeOffset)


var relativeTo : Node2D
var relativeToPosPrev : Vector2
func moveRelativeTo(_relativeTo : Node2D):
	relativeTo=_relativeTo
	if relativeTo!=null:
		relativeToPosPrev=relativeTo.position
