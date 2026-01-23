class_name Reflector
extends Node2D

var area : Area2D
var shape : RectangleShape2D
var line : Line2D
var tip0 : Sprite2D
var tip1 : Sprite2D
var cd : float

func _enter_tree():
	area=get_child(0)
	shape=area.get_child(0).shape
	line=get_child(1)
	tip0=get_child(2)
	tip1=get_child(3)
	var scaleSaved : Vector2 = scale
	scale=Vector2.ONE
	line.set_point_position(0,Vector2(-500*scaleSaved.x,0))
	line.set_point_position(1,Vector2(500*scaleSaved.x,0))
	tip0.position=Vector2(-500*scaleSaved.x,0)
	tip1.position=Vector2(500*scaleSaved.x,0)
	shape.size.x=scaleSaved.x*1000
	area.body_entered.connect(onBodyEntered)

func _physics_process(delta):
	cd=max(0,cd-delta)

func onBodyEntered(other : Node2D):
	if cd>0:
		return
	if not other is Projectile:
		return
	var p : Projectile = other
	p.linear_velocity=p.linear_velocity.reflect(MathS.DegToVec(rotation_degrees-90))
	p.resetFreeze()
	p.boost()
	cd=0.1
