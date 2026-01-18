class_name SmoothScale
extends Node2D

enum StartMode{
    A,B,AtoB,BtoA
}
@export var startMode : StartMode
@export var a : Vector2 = Vector2.ONE
@export var b : Vector2 = Vector2(0.5,0.5)
@export var speedAtoB : float = 3
@export var speedBtoA : float = 3
@export var easeAtoB : MathS.EasingMethod
@export var easeBtoA : MathS.EasingMethod
var _easeP : float
var _moveToA : bool
var _from : Vector2

func _ready():
    match startMode:
        StartMode.A:
            scale=a
            set_process(false)
        StartMode.B:
            scale=b
            set_process(false)
        StartMode.AtoB:
            scale=a
            TriggerToB()
        StartMode.BtoA:
            scale=b
            TriggerToA()


func _process(delta):
    _easeP+=delta*(speedBtoA if _moveToA else speedAtoB)
    var tar : Vector2 = a if _moveToA else b
    var ease : MathS.EasingMethod = easeBtoA if _moveToA else easeAtoB
    scale=_from.lerp(tar,MathS.Ease(_easeP,ease))
    if _easeP>=1:
        scale=tar
        set_process(false)

func TriggerToA():
    _easeP=0
    _from=scale
    _moveToA=true
    set_process(true)
func TriggerToB():
    _easeP=0
    _from=scale
    _moveToA=false
    set_process(true)
