class_name Shaker
extends Node2D

const Small = 4
const Medium = 8
const Large = 12

@export var duration : float = 0.5
@export var rotationMode : bool = false
@export var easeM : MathS.EasingMethod = MathS.EasingMethod.Linear
var _remainingDuration=0
var _curStrength=0

func _enter_tree():
    _remainingDuration = 0
    set_process(false)

func Trigger(newStrength=Medium):
    _remainingDuration=duration
    _curStrength=newStrength
    set_process(true)

func _process(delta):
    var p = MathS.Ease(_remainingDuration / duration, easeM)
    if rotationMode:
        rotation_degrees = MathS.RandSigned() * p * _curStrength
    else:
        position = MathS.RandVec2() * p * _curStrength
    
    _remainingDuration-=delta
    if _remainingDuration <= 0:
        position=Vector2.ZERO
        rotation_degrees=0
        set_process(false)
