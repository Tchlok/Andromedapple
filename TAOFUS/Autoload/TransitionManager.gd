extends Node2D

const TransitionDurationIn = 0.3
const TransitionDurationOut = 0.3

signal EV_TransitionFinished
signal EV_TransitionCovered
signal EV_VisualsUpdate #Should only be used for visuals, doesn't get reset

var modeIn : bool
var t : float
var _transitioning

func _ready():
	var effect : PackedScene = load("res://Scenes/TransitionEffect.tscn")
	add_child(effect.instantiate())
	process_mode=Node.PROCESS_MODE_ALWAYS

func IsTransitioning():
	return _transitioning

#path or packed
var _curScene
func TransitionScene(sceneStr : String, canOverride : bool = false):
	if IsTransitioning() and not canOverride:
		return
	_curScene = load(sceneStr)
	EV_TransitionCovered.connect(_TransitionSceneCovered)
	TransitionStart(canOverride)

func _TransitionSceneCovered():
	if _curScene is PackedScene:
		get_tree().change_scene_to_packed(_curScene)
	else:
		get_tree().change_scene_to_file(_curScene)

func TransitionStart(canOverride : bool = false):
	if IsTransitioning() and not canOverride:
		return
	modeIn=true
	t=0
	_transitioning=true

func _process(delta):
	var duration =  TransitionDurationIn if modeIn else TransitionDurationOut
	t+=delta
	var prog = MathS.Clamp01(t/duration)
	if IsTransitioning():
		EV_VisualsUpdate.emit(prog, modeIn)
	if prog == 1:
		if modeIn:
			EV_TransitionCovered.emit()
			modeIn=false
			t=0
		else:
			EV_TransitionFinished.emit()
			MathS.ClearSignal(EV_TransitionFinished)
			MathS.ClearSignal(EV_TransitionCovered)
			_transitioning=false
