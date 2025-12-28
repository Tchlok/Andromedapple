extends Node

const ParticlesPath = "res://Scenes/Particles/"
const ParticlesPrefix = "Particle"
const DefaultZIndex = 10

func _enter_tree():
	process_mode = Node.PROCESS_MODE_ALWAYS

func SpawnFromName(parName : String, position : Vector2, zIndex : int = DefaultZIndex):
	var packed : PackedScene = load(ParticlesPath + ParticlesPrefix + parName + ".tscn");
	return SpawnFromPacked(packed, position, zIndex)

func SpawnFromPacked(packed : PackedScene, position : Vector2, zIndex : int = DefaultZIndex):
	var par = packed.instantiate()
	if not (par is CPUParticles2D or par is GPUParticles2D):
		printerr("Type of Packed is not Particle")
	par.position = position
	par.z_index = zIndex
	par.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(par)
	return par

func ClearParticles():
	for i in get_child_count():
		get_child(i).call_deferred("queue_free")
