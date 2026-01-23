class_name Booster
extends Node2D

var area : Area2D
var tog : SmoothToggle

func _enter_tree():
    area=get_child(0)
    tog=get_child(1)
    area.body_entered.connect(onBodyEntered)
    eventConnected=false

var eventConnected : bool

func onBodyEntered(other : Node2D):
    if not other is Projectile:
        return
    var p : Projectile = other
    p.resetFreeze()
    p.boost()
    tog.TriggerOff()
    area.set_deferred("monitoring",false)
    if not eventConnected:
        p.level.EV_ProjectileRemoved.connect(onProjectileRemoved)
        eventConnected=true

func onProjectileRemoved(projectile:Projectile,destroyed:bool,other:Node2D):
    tog.TriggerOn()
    area.monitoring=true

