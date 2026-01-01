class_name Level
extends Node2D

@export var testLog : TestLog
@export var testLevelHeight : float = 5000

signal EV_LevelSetup

signal EV_TreeSpawned
signal EV_FruitSpawned
signal EV_ProjectileSpawned

@export var game : Game

@export var holderPlanet : Node2D
var planets : Array[Planet]

var trees : Array[FruitTree]
var fruits : Array[Fruit]

@export var holderProjectile : Node2D
var projectiles : Array[Projectile]
const packedProjecilePath : String = "res://Scenes/Projectile.tscn"


func _ready():
	for p : Planet in holderPlanet.get_children():
		planets.append(p)
	EV_LevelSetup.emit()


func spawnTree(treePacked : PackedScene, planet : Planet, position : Vector2):
	var tree : FruitTree = treePacked.instantiate()
	tree.position=position
	planet.add_child(tree)
	trees.append(tree)
	tree.setup(self)
	EV_TreeSpawned.emit(tree)

func spawnFruit(fruitPacked : PackedScene, tree : FruitTree, position : Vector2):
	var fruit : Fruit = fruitPacked.instantiate()
	fruit.position=position
	tree.add_child(fruit)
	fruits.append(fruit)
	fruit.setup()
	EV_FruitSpawned.emit(fruit)

func removeFruit(fruit : Fruit):
	pass

func spawnProjectile(fruit : Fruit, position : Vector2, direction : Vector2, speed : float):
	var packed : PackedScene = load(packedProjecilePath)
	var projectile : Projectile = packed.instantiate()
	projectile.position=position
	holderProjectile.add_child(projectile)
	projectile.setup(direction,speed)
	EV_ProjectileSpawned.emit(projectile)

func fruitMouseEvents(getsEvents:bool):
	for f in fruits:
		f.control.mouse_filter=Control.MouseFilter.MOUSE_FILTER_STOP if getsEvents else Control.MouseFilter.MOUSE_FILTER_IGNORE

func planetOfTree(tree : FruitTree):
	var p : Planet = tree.get_parent()
	return p

func treeOfFruit(fruit : Fruit):
	var t : FruitTree = fruit.get_parent()
	return t

func planetOfFruit(fruit : Fruit):
	var p : Planet = planetOfTree(treeOfFruit(fruit))
	return p
