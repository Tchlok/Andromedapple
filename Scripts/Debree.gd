class_name Debree
extends Area2D

var shaker : Shaker
var sp : Sprite2D

func _enter_tree():
    collision_layer=2
    collision_mask=0
    shaker=get_child(1)
    sp=shaker.get_child(0)

func hitByProj(projectile : Projectile):
    shaker.Trigger()