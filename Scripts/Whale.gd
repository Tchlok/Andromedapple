class_name Whale
extends Area2D

const maxSpeed : float = 900
const accel : float = 5000
const decel : float = 2000

var colShape : CollisionShape2D
var shape : CircleShape2D
var squash : SquashAnchor
var shaker : Shaker
var rot : Node2D
var dead : bool

var level : Level
var proj : Projectile

var velocity : Vector2

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

func _physics_process(delta):
	if movesToTarget():
		velocity+=position.direction_to(proj.position)*accel*delta
		velocity=velocity.limit_length(maxSpeed)
	else:
		velocity-=velocity.normalized()*decel*delta
		if velocity.length()<=20:
			velocity=Vector2.ZERO


	if velocity.length()>20:
		rot.rotation_degrees=MathS.VecToDeg(velocity.normalized())

	position+=velocity*delta

func movesToTarget():
	return proj!=null and not dead and lineOfSight()

func lineOfSight():
	var colMask = 1
	var query = PhysicsRayQueryParameters2D.create(position,proj.position,colMask)
	query.collide_with_areas=true
	query.collide_with_bodies=false
	var spaceState = get_world_2d().direct_space_state
	var result : Dictionary = spaceState.intersect_ray(query)
	return result.is_empty()

func onProjectileSpawned(projectile : Projectile):
	if dead:
		return
	proj=projectile

func onProjectileRemoved(projectile : Projectile, destroyed : bool, other : Node2D):
	proj=null
	if dead:
		return

func onAreaEntered(area : Area2D):
	pass
func onBodyEntered(body : Node2D):
	if body is Projectile:
		level.removeProjectile(body,true,self)
		eat(body)

func eat(projectile : Projectile):
	pass
