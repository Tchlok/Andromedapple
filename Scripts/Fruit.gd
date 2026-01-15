class_name Fruit
extends Node2D

@export var sp : Sprite2D
@export var testSelectedBackdrop : Sprite2D

func _enter_tree():
    setFruitState(FruitState.Normal)

#TODO not sure if this is needed
func setup():
    pass

func onFocusEntered():
    EV_enter.emit(self)
func onFocusExit():
    EV_exit.emit(self)
signal EV_enter
signal EV_exit

enum FruitState{Normal,Selected,Aiming}
var fruitVisualState : FruitState
func setFruitState(_newState : FruitState):
    fruitVisualState=_newState
    testSelectedBackdrop.visible=fruitVisualState==FruitState.Selected
    sp.modulate=Color(1,0,0,1) if fruitVisualState==FruitState.Aiming else Color(1,1,1,1)