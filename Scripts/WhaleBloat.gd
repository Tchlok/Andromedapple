class_name WhaleBloat
extends Whale

var bloated : bool
const mass : float = 13000000
const removedEatThreshold : float = 700

func _physics_process(delta):
    super._physics_process(delta)

func movesToTarget():
    return super.movesToTarget() and not bloated

func eat(projectile : Projectile):
    print("eat")
    bloat()

func onProjectileRemoved(projectile : Projectile, destroyed : bool, other : Node2D):
    if position.distance_to(projectile.position)<=removedEatThreshold and aggro:
        bloat()
    proj=null

func bloat():
    if bloated:
        return
    level.spawnGravitySource(self,Vector2.ZERO,mass, true)
    bloated=true