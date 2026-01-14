class_name Asteroid
extends Area2D

@export var density : float = 300
var radius : float
var grav : GravitySource
var level : Level
var mass : float
var shaker : Shaker
var sp : Sprite2D
var shape : CircleShape2D
func _enter_tree():
	var colShape : CollisionShape2D = get_child(0)
	shape=colShape.shape
	shaker=get_child(1)
	sp=shaker.get_child(0)
	collision_layer=4
	collision_mask=0

func _ready():
	setRadius(scale.x*100)
	scale=Vector2.ONE


func setRadius(_radius):
	radius=_radius
	mass=density*pow(radius,2)
	if grav==null:
		grav=level.spawnGravitySource(self,Vector2.ZERO,mass,true)
	sp.scale=Vector2.ONE*(radius/100)
	shape.radius=radius

func hitByProj(proj : Projectile):
	shaker.Trigger()
