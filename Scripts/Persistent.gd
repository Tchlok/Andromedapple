extends Node2D

var layoutPacked : PackedScene
func TransitionGame():
    TransitionManager.TransitionScene("res://Scenes/Main.tscn")
func TransitionMenu():
    TransitionManager.TransitionScene("res://Scenes/Menu.tscn")