class_name GameUi
extends Control
@export var cam : Cam
@export var testLog : TestLog

@export var zoomSpringDamp : float
@export var zoomSpringRigidity : float
var zoomVelocity : float
var zoom : float

@export var posSpringDamp : float
@export var posSpringRigidity : float
var posVelocity : Vector2

@export var inputGuideLeft : InputGuide
@export var inputGuideRight : InputGuide
@export var speedIcon : SmoothModulate

func _process(delta):
	var zoomOffset : float = zoom-cam.camera.zoom.x
	zoomVelocity+=-zoomSpringRigidity*zoomOffset-(zoomSpringDamp*zoomVelocity)
	zoom+=zoomVelocity*delta*2
	scale=Vector2.ONE/zoom

	var posOffset : Vector2 = global_position-cam.global_position
	posVelocity+=-posSpringRigidity*posOffset-(posSpringDamp*posVelocity)
	position+=posVelocity*delta

func updateInputText(textLeft : String, textRight : String):
	inputGuideLeft.update(textLeft)
	inputGuideRight.update(textRight)
func updateSpeedIcon(on : bool):
	if on:
		speedIcon.TriggerToA()
	else:
		speedIcon.TriggerToB()
