class_name AimVisuals
extends Node2D

@export var line : Line2D
var endPoint : Vector2

func destroy():
    queue_free()

func update(_endPoint : Vector2):
    endPoint = _endPoint
    line.set_point_position(1,endPoint)