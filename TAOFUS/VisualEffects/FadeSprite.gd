class_name FadeSprite
extends Sprite2D

@export var duration : float = 1
@export var startOpacity : float = 1
@export var easeM : MathS.EasingMethod = MathS.EasingMethod.OutSquare
var _remainingDuration
func _enter_tree():
	_remainingDuration = duration
	startOpacity=modulate.a

func _process(delta):
	_remainingDuration-=delta
	modulate.a = startOpacity*MathS.Ease(_remainingDuration/duration,easeM)
	if _remainingDuration <= 0:
		queue_free()
