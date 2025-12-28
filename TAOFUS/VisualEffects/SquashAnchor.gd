class_name  SquashAnchor
extends Node2D

@export var duration : float = 0.5

const Small = 0.15
const Medium = 0.35
const Large = 0.5

var _squashMode
var _remainingDuration=0
var _curStrength=0
var _ease : MathS.EasingMethod

func _enter_tree():
	set_process(false)



func TriggerSquash(newStrength=Medium, newEase:MathS.EasingMethod = MathS.EasingMethod.OutSquare):
	_ease = newEase
	_curStrength = newStrength
	_remainingDuration=duration
	_squashMode=true
	set_process(true)
func TriggerStretch(newStrength=Medium, eM:MathS.EasingMethod = MathS.EasingMethod.OutSquare):
	TriggerSquash(newStrength, eM)
	_squashMode=false

func _process(delta):
	var v : Vector2
	v.y = 1 - _curStrength * MathS.Ease(_remainingDuration / duration,_ease)
	v.x = 1 / v.y
	
	if _squashMode:
		scale = Vector2(v.x, v.y)
	else:
		scale = Vector2(v.y, v.x)

	_remainingDuration-=delta
	if _remainingDuration <= 0:
		set_process(false)
