class_name Projectile
extends RigidBody2D

var initialDirection : Vector2
var initialSpeed : float

func setup(_initialDirection : Vector2, _initialSpeed : float):
    initialDirection=_initialDirection
    initialSpeed=_initialSpeed
    linear_velocity=initialDirection*initialSpeed