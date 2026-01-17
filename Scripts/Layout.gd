class_name Layout
extends Node2D

@export var rect : ColorRect
var boundsCenter : Vector2
var boundsDim : Vector2

func _enter_tree():
	boundsCenter=rect.position+rect.size*rect.scale*0.5
	boundsDim=Vector2(rect.size.x*rect.scale.x,rect.size.y*rect.scale.y)
	rect.visible=false
