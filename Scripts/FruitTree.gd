class_name FruitTree
extends Node2D

@export var cameraHeight : float = 100
@export var packedFruit : PackedScene
@export var spawnPoints : Node2D
@export var tog : SmoothToggle

func _enter_tree():
	pass

func _ready():
	tog.TriggerOn()
	for sp : Node2D in spawnPoints.get_children():
		level.spawnFruit(packedFruit, self, sp.position)

var level : Level
