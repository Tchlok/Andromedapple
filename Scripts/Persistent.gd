extends Node2D

var layoutPacked : PackedScene
var layoutCords : Vector2i
var celebrate : bool = false

func LevelCleared():
    if not Save.clearedLevels.has(layoutCords):
        print("NEW UNLOCK")
        celebrate=true
        Save.clearedLevels.append(layoutCords)
        Save.updateSave()

func TransitionGame():
    TransitionManager.TransitionScene("res://Scenes/Main.tscn")
func TransitionMenu():
    TransitionManager.TransitionScene("res://Scenes/Menu.tscn")
