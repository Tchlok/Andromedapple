class_name ParSelfFreeGPU
extends GPUParticles2D

func _enter_tree():
    finished.connect(_onFinished)
    emitting=true
    one_shot=true

func _onFinished():
    queue_free()