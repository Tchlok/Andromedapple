class_name TreePlaceVisuals
extends Node2D

@export var point : Node2D

func destroy():
	queue_free()

func update(dir : Vector2, radius : float):
	rotation_degrees=MathS.VecToDeg(dir)
	point.position=Vector2.RIGHT*radius
