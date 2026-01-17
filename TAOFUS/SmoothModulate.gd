class_name SmoothModulate
extends Node2D

enum StartMode{
    A,B,AtoB,BtoA
}
@export var startMode : StartMode
@export var a : Color = Color(1,1,1,1)
@export var b : Color = Color(1,1,1,0)
@export var speedAtoB : float = 3
@export var speedBtoA : float = 3
@export var easeAtoB : MathS.EasingMethod
@export var easeBtoA : MathS.EasingMethod
var _easeP : float
var _moveToA : bool
var _from : Color

func _ready():
    match startMode:
        StartMode.A:
            modulate=a
            set_process(false)
        StartMode.B:
            modulate=b
            set_process(false)
        StartMode.AtoB:
            modulate=a
            TriggerToB()
        StartMode.BtoA:
            modulate=b
            TriggerToA()


func _process(delta):
    _easeP+=delta*(speedBtoA if _moveToA else speedAtoB)
    var tar : Color = a if _moveToA else b
    var ease : MathS.EasingMethod = easeBtoA if _moveToA else easeAtoB
    modulate=_from.lerp(tar,MathS.Ease(_easeP,ease))
    if _easeP>=1:
        modulate=tar
        set_process(false)

func TriggerToA():
    _easeP=0
    _from=modulate
    _moveToA=true
    set_process(true)
func TriggerToB():
    _easeP=0
    _from=modulate
    _moveToA=false
    set_process(true)
