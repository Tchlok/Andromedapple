class_name ProjectileTrail
extends Line2D

var level : Level
var projectile : Projectile
var p : Array[Vector2]

@export var timeBetweenPoints : float

@export var maxOpacity : float
@export var minOpacity : float
@export var opacityLossStep : float

var curPointCd : float

func _enter_tree():
	level.EV_ProjectileSpawned.connect(onProjectileSpawned)
	level.EV_ProjectileRemoved.connect(onProjectileRemoved)
	z_index=-400
	modulate.a=maxOpacity

func onProjectileSpawned(_projectile : Projectile):
	if projectile==_projectile:
		return
	modulate.a=max(modulate.a-opacityLossStep,minOpacity)
	z_index-=1

func onProjectileRemoved(_projectile : Projectile, _destroyed : bool, _other : Node2D):
	if projectile==_projectile:
		projectile=null
		p.clear()

func _physics_process(delta):
	if projectile==null:
		pass
	else:
		curPointCd-=delta
		if curPointCd<=0:
			curPointCd=timeBetweenPoints
			print(curPointCd)
			p.append(projectile.global_position)
			points=p
