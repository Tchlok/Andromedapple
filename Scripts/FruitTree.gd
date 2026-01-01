class_name FruitTree
extends Node2D

@export var packedFruit : PackedScene
@export var spawnPoints : Node2D
@export var tog : SmoothToggle

func _ready():
	tog.TriggerOn()
	tog.EV_ToggleEnd.connect(onToggleEnd)

var level : Level

func setup(_level : Level):
	level=_level

func onToggleEnd(tog, on):
	for sp : Node2D in spawnPoints.get_children():
		level.spawnFruit(packedFruit, self, sp.global_position)
	EV_FruitTreeReady.emit(self)
	

signal EV_FruitTreeReady
