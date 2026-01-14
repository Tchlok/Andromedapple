class_name Projectile
extends RigidBody2D

var startPos : Vector2

var level : Level
var ignoredOrigin : GravitySource

var initialDirection : Vector2
var initialSpeed : float

var gravitySources : Array[GravitySource]
var prevGravitySources : Array[GravitySource]

@export var timeToFreeze : float
var _freezeT : float

@export var colShape : CollisionShape2D
@export var area : Area2D
@export var areaColShape : CollisionShape2D

@export var initialSpeedMin : float
@export var initialSpeedMax : float

const exitBoost : float = 100

func _enter_tree():
	areaColShape.shape=colShape.shape
	area.area_entered.connect(onAreaEntered)
func _ready():
	startPos=global_position

func onAreaEntered(other : Area2D):
	if other is Planet:
		var planet : Planet = other
		if planet.isOccupied():
			level.removeProjectile(self,true,other)
		else:
			level.removeProjectile(self,false,other)
	elif other is Debree:
		var debree : Debree = other
		debree.hitByProj(self)
		level.removeProjectile(self,true,other)
	elif other is Asteroid:
		var asteroid : Asteroid = other
		asteroid.hitByProj(self)
		level.removeProjectile(self,true,other)
func setup(_initialDirection : Vector2, _p : float, _ignoredOrigin : GravitySource):
	ignoredOrigin=_ignoredOrigin
	initialDirection=_initialDirection
	initialSpeed=lerp(initialSpeedMin,initialSpeedMax,_p)
	linear_velocity=initialDirection*initialSpeed

var totalGravStep : Vector2

func freezeP():
	return MathS.Clamp01(_freezeT/timeToFreeze)

func _physics_process(delta):
	linear_velocity+=totalGravStep
	_freezeT+=delta
	totalGravStep=Vector2.ZERO
	for grav : GravitySource in gravitySources:
		if not prevGravitySources.has(grav):
			_onGravitySourceEntered(grav)
		if grav._hasAtmosphere:
			_freezeT=0
	for grav : GravitySource in prevGravitySources:
		if not gravitySources.has(grav):
			_onGravitySourceExited(grav)
	prevGravitySources=gravitySources.duplicate()
	gravitySources.clear()

	if freezeP()==1:
		level.removeProjectile(self,true,null)

func _process(delta):
	modulate=Color(1,1,1,1).lerp(Color(0,0,1,1),freezeP())

func _onGravitySourceEntered(gravitySource:GravitySource):
	print("Gravity Source Enter")
func _onGravitySourceExited(gravitySource:GravitySource):
	print("Gravity Source Exit")
	if gravitySource==ignoredOrigin:
		ignoredOrigin=null
		print("Left origin gravity zone")
	else:
		pass

func gravStep(amount : Vector2, delta : float, gravSource : GravitySource):
	totalGravStep+=amount*delta
