class_name AimVisuals
extends Node2D

@export var line : Line2D
var endPoint : Vector2
var p : float

func destroy():
    queue_free()

func update(_endPoint : Vector2, _p : float):
    endPoint = _endPoint
    p=_p
    line.set_point_position(1,endPoint)