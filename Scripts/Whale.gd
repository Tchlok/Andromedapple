class_name Whale
extends Area2D

const maxSpeed : float = 3000
const accelDur : float = 0
const alertDelay : float = 0

var accelT : float

const fov : float = 90
const dist : float = 450000

var colShape : CollisionShape2D
var shape : CircleShape2D
var squash : SquashAnchor
var shaker : Shaker
var rot : Node2D

var level : Level
var proj : Projectile

var velocity : Vector2

var aggro : bool

func _enter_tree():
	colShape=get_child(0)
	shape=colShape.shape
	squash=get_child(1)
	shaker=squash.get_child(0)
	rot=shaker.get_child(0)

	level=get_parent().get_parent()
	level.EV_ProjectileSpawned.connect(onProjectileSpawned)
	level.EV_ProjectileRemoved.connect(onProjectileRemoved)
	
	area_entered.connect(onAreaEntered)
	body_entered.connect(onBodyEntered)

	rot.rotation=rotation
	rotation=0

func _physics_process(delta):
	if movesToTarget():
		accelT+=delta
		velocity=position.direction_to(proj.position)*maxSpeed*MathS.Clamp01((accelT-alertDelay)/accelDur)
	else:
		accelT=0
		velocity=Vector2.ZERO
		if velocity.length()<=20:
			velocity=Vector2.ZERO


	if velocity.length()>20:
		rot.rotation_degrees=MathS.VecToDeg(velocity.normalized())

	position+=velocity*delta

func movesToTarget():
	if proj==null:
		aggro=false
		return false
	var los : bool = lineOfSight()
	if not los:
		aggro=false
	elif not aggro:
		var angleToProj : float = rad_to_deg(position.direction_to(proj.position).angle_to(rot.transform.x))
		if abs(angleToProj)<=fov/2 and proj.position.distance_to(position)<=dist:
			aggro=true
			print("Whale aggro triggered " + str(abs(angleToProj)) + "  " + str(proj.position.distance_to(position)))
	return aggro

func lineOfSight():
	var colMask = 3
	var query = PhysicsRayQueryParameters2D.create(position,proj.position,colMask)
	query.collide_with_areas=true
	query.collide_with_bodies=false
	var spaceState = get_world_2d().direct_space_state
	var result : Dictionary = spaceState.intersect_ray(query)
	return result.is_empty()

func onProjectileSpawned(projectile : Projectile):
	proj=projectile

func onProjectileRemoved(projectile : Projectile, destroyed : bool, other : Node2D):
	proj=null

func onAreaEntered(area : Area2D):
	pass
func onBodyEntered(body : Node2D):
	if body is Projectile:
		level.removeProjectile(body,true,self)
		eat(body)

func eat(projectile : Projectile):
	pass
