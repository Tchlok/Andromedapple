class_name WhaleBloat
extends Whale

var bloated : bool
const mass : float = 9000000

func _physics_process(delta):
    super._physics_process(delta)

func movesToTarget():
    return super.movesToTarget() and not bloated

func eat(projectile : Projectile):
    if bloated:
        return
    level.spawnGravitySource(self,Vector2.ZERO,mass, true)
    bloated=true