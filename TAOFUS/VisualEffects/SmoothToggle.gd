class_name SmoothToggle
extends Node2D

enum StartMode {
	On, Off, AnimOn, AnimOff
}
@export var _startMode : StartMode = StartMode.AnimOn
@export var speedIn : float = 3
@export var speedOut : float = 3
@export var _easeIn : MathS.EasingMethod
@export var _easeOut : MathS.EasingMethod
var _on
var _easeP

var selfDestruct : bool = false #calls queueFree upon Toggle Off Finishing.

signal EV_ToggleEnd

func _enter_tree():
	match _startMode:
		StartMode.On:
			_easeP=1
			_on=true
			scale = Vector2.ONE
			set_process(false)
		StartMode.Off:
			_easeP=0
			_on=false
			scale = Vector2.ZERO
			set_process(false)
		StartMode.AnimOn:
			_on=false
			scale = Vector2.ZERO
			TriggerOn()
		StartMode.AnimOff:
			_on=true
			scale = Vector2.ONE
			TriggerOff()

func IsOn():
	return _on

func TriggerOn():
	if _on:
		return
	_on=true
	_easeP=0
	set_process(true)
func TriggerOff():
	if !_on:
		return
	_on=false
	_easeP=1
	set_process(true)

func _process(delta):
	if _on:
		_easeP+=delta*speedIn
		_easeP = MathS.Clamp01(_easeP)
		scale = Vector2.ONE * MathS.Ease(_easeP, _easeIn)
	else:
		_easeP-=delta*speedOut
		_easeP = MathS.Clamp01(_easeP)
		scale = Vector2.ONE * MathS.Ease(_easeP, _easeOut)
	
	if (_easeP == 1 and _on) or (_easeP == 0 and not _on):
		EV_ToggleEnd.emit(self,_on)
		if (not _on) and selfDestruct:
			queue_free()
		set_process(false)
