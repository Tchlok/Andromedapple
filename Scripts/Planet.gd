class_name Planet
extends StaticBody2D

func plantTree(packed : PackedScene, position : Vector2):
    var tree : Tree = packed.instantiate()

func _physics_process(delta):
    position+=Vector2.UP*100*delta