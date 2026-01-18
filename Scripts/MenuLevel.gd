class_name MenuLevel
extends Control

@export var layout : PackedScene
@export var unlocks : Array[MenuLevel]
var cord : Vector2i
var menu : Menu
enum LevelState{Disabled,Unlocked,Cleared}
var levelState : LevelState

var center : Node2D
var smScale : SmoothScale
var smMod : SmoothModulate
var sp : Sprite2D

func activate(_menu : Menu,_cord : Vector2i, _cleared : bool):
	if _cleared:
		levelState=LevelState.Cleared
		modulate.a=1
	else:
		modulate.a=0.5
		levelState=LevelState.Unlocked
	mouse_filter=Control.MOUSE_FILTER_STOP
	menu=_menu
	cord=_cord

func _enter_tree():
	center = get_child(0)
	smScale=center.get_child(0)
	smMod=smScale.get_child(0)
	sp=smMod.get_child(0)
	
	center.position=size*0.5
	modulate.a=0
	levelState=LevelState.Disabled
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(onMouseEntered)
	mouse_exited.connect(onMouseExited)
func onMouseEntered():
	menu.onMouseEntered(self)
	smMod.TriggerToA()
	smScale.TriggerToA()
	
func onMouseExited():
	menu.onMouseExited(self)
	smMod.TriggerToB()
	smScale.TriggerToB()

func getPos():
	return center.global_position
