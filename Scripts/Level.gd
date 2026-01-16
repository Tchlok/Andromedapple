class_name Level
extends Node2D

@export var testLog : TestLog
@export var testLevelHeight : float = 5000

signal EV_LevelSetup

signal EV_TreeSpawned
signal EV_FruitSpawned
signal EV_ProjectileSpawned
signal EV_GravitySourceSpawned

signal EV_FruitRemoved
signal EV_ProjectileRemoved

@export var game : Game

var layout : Node2D

var planets : Array[Planet]
var trees : Array[FruitTree]
var fruits : Array[Fruit]
var gravitySources : Array[GravitySource]
var asteroids : Array[Asteroid]


var occupiedPlanets : int

@export var holderProjectile : Node2D #TODO remove?
var projectiles : Array[Projectile]
const packedProjectilePath : String = "res://Scenes/Projectile.tscn"
const packedGravitySourcePath : String = "res://Scenes/GravitySource.tscn"
const packedProjectilePathPath : String = "res://Scenes/ProjectileTrail.tscn"

func _enter_tree():
	layout=Persistent.layoutPacked.instantiate()
	add_child(layout)
	for n : Node2D in layout.get_children():
		if n is Planet:
			planets.append(n)
			n.level=self
		elif n is Asteroid:
			asteroids.append(n)
			n.level=self
	#for p : Planet in holderPlanet.get_children():
	#	planets.append(p)
	#	p.level=self

func _ready():
	EV_LevelSetup.emit()

func getOccupationP():
	return float(occupiedPlanets-1)/float(planets.size()-1)

func spawnTree(treePacked : PackedScene, planet : Planet, position : Vector2, rotation : float):
	if planet.isOccupied():
		return
	var tree : FruitTree = treePacked.instantiate()
	tree.level=self
	tree.position=position
	tree.rotation_degrees=rotation
	trees.append(tree)
	planet.add_child(tree)
	planet.treeOccupiedSetup(tree)
	EV_TreeSpawned.emit(tree)
	return tree

func spawnFruit(fruitPacked : PackedScene, tree : FruitTree, position : Vector2):
	var fruit : Fruit = fruitPacked.instantiate()
	fruit.position=position
	fruits.append(fruit)
	tree.add_child(fruit)
	fruit.setup()
	EV_FruitSpawned.emit(fruit)
	return fruit


func spawnProjectile(fruit : Fruit, position : Vector2, direction : Vector2):
	var packedProj : PackedScene = load(packedProjectilePath)
	var projectile : Projectile = packedProj.instantiate()
	projectile.level=self
	projectiles.append(projectile)
	projectile.position=position
	holderProjectile.add_child(projectile)
	projectile.setup(direction, planetOfFruit(fruit).grav)

	var packedTrail : PackedScene = load(packedProjectilePathPath)
	var trail : ProjectileTrail = packedTrail.instantiate()
	trail.level=self
	trail.projectile=projectile
	add_child(trail)

	EV_ProjectileSpawned.emit(projectile)
	return projectile


func removeFruit(fruit : Fruit):
	fruits.erase(fruit)
	fruit.queue_free()
	EV_FruitRemoved.emit(fruit)

func removeProjectile(projectile : Projectile, destroyed : bool, other : Node2D = null):
	projectiles.erase(projectile)
	projectile.queue_free()
	print("Proj distance from start : " + str(projectile.global_position.distance_to(projectile.startPos)))
	EV_ProjectileRemoved.emit(projectile,destroyed,other)


func spawnGravitySource(attachTo : Node2D, position : Vector2, mass : float, hasAtmosphere : bool):
	var packed : PackedScene = load(packedGravitySourcePath)
	var gravitySource : GravitySource = packed.instantiate()
	gravitySources.append(gravitySource)
	gravitySource.updateMass(mass)
	gravitySource.updateAtmosphere(hasAtmosphere)
	if attachTo==null:
		add_child(gravitySource)
	else:
		attachTo.add_child(gravitySource)
	EV_GravitySourceSpawned.emit(gravitySource)
	return gravitySource

func _physics_process(delta: float):
	for proj in projectiles:
		for grav in gravitySources:
			proj.gravStep(grav.affect(proj.global_position,delta,proj),delta, grav)

func planetOfTree(tree : FruitTree):
	var p : Planet = tree.get_parent()
	return p

func treeOfFruit(fruit : Fruit):
	var t : FruitTree = fruit.get_parent()
	return t

func planetOfFruit(fruit : Fruit):
	var p : Planet = planetOfTree(treeOfFruit(fruit))
	return p

func fruitsOfTree(tree : FruitTree):
	var result : Array[Fruit]
	for f : Fruit in fruits:
		if treeOfFruit(f)==tree:
			result.append(f)
	return result

func treeOfPlanet(planet : Planet):
	return planet.tree
