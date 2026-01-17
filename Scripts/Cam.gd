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
@export var zoomPow : float

@export var speedMove : float

func _ready():
	_layoutZoomMode=true
	camera.zoom.x=float(1920)/level.layout.boundsDim.x
	camera.zoom.y=camera.zoom.x
	position=level.layout.boundsCenter
func setZoomT(newT : float, instant : bool = false):
	newT=MathS.Clamp01(newT)
	_zoomT=newT
	if instant:
		camera.zoom=Vector2.ONE*lerp(minZoom,maxZoom,pow(_zoomT,zoomPow))

var targetPosition : Vector2
var mousePosPrev : Vector2
var mouseDelta : Vector2
func _process(delta):
	mouseDelta=mousePosPrev-get_local_mouse_position()
	var targetZoom
	
	if not _layoutZoomMode:
		targetZoom=lerp(minZoom,maxZoom,pow(_zoomT,zoomPow))
	else:
		targetZoom=float(1920)/level.layout.boundsDim.x
		targetPosition=level.layout.boundsCenter

	if camera.zoom.x!=targetZoom:
		camera.zoom.x+=(targetZoom-camera.zoom.x)*delta*speedZoom
		if abs(camera.zoom.x-targetZoom)<0.002:
			camera.zoom.x=targetZoom
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

var _layoutZoomMode : bool

func stepZoomIn():
	setZoomT(_zoomT+stepZoom)
func stepZoomOut():
	setZoomT(_zoomT-stepZoom)
func zoomInMin():
	setZoomT(maxZoom)
func zoomOutMax():
	setZoomT(minZoom)
func zoomFullLayout():
	relativeTo=null
	_layoutZoomMode=true

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
	if _layoutZoomMode:
		_layoutZoomMode=false
	relativeTo=_relativeTo
	if relativeTo!=null:
		relativeToPosPrev=relativeTo.position
