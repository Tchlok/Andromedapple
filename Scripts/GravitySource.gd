class_name GravitySource
extends Node2D

@export var circ : DrawCircle
var influenceRadius : float # radius where the force >= discardThreshold

const discardThreshold : float = 170000 # forces below this threshold will not be applied
const gravConstant : float = 7000
const gravPow : float = 2
var _mass : float
var _hasAtmosphere : bool
func updateMass(newMass : float):
    _mass=newMass
    influenceRadius=sqrt((gravConstant*_mass)/discardThreshold)
    circ.Radius(influenceRadius)
func updateAtmosphere(newHasAtmosphere : bool):
    _hasAtmosphere=newHasAtmosphere

func _physics_process(delta):
    if _affected:
        circ.modulate.a=1
    else:
        circ.modulate.a=0.4
    _affected=false

var _affected : bool
func affect(otherGlobalPosition : Vector2, delta : float, projectile : Projectile):
    var dist = global_position.distance_to(otherGlobalPosition)
    if dist > influenceRadius:
        return Vector2.ZERO
    var force = gravConstant*(_mass/pow(dist,gravPow))
    projectile.gravitySources.append(self)
    if projectile.ignoredOrigin==self:
        return Vector2.ZERO
    _affected=true
    return otherGlobalPosition.direction_to(global_position)*force*delta
