class_name AfterimageTrail
extends Node2D

const FadeSpritePath = "res://Common/FadeSprite.tscn"

@export var emitting : bool
@export var cooldown : float = 0.5
@export var duration : float = 1
@export var easeM : MathS.EasingMethod = MathS.EasingMethod.OutSquare
@export_range(0,1) var startOpacity : float = 0.6
@export var copyFrom : Sprite2D

var _curCd
var _packed : PackedScene

func _enter_tree():
    _curCd = cooldown
    _packed = load(FadeSpritePath)

func _process(delta):
    if not emitting:
        return
    _curCd-=delta
    if _curCd <= 0:
        _curCd+=cooldown
        var fadeSprite : FadeSprite = _packed.instantiate()
        fadeSprite.texture = copyFrom.texture
        fadeSprite.modulate = modulate
        fadeSprite.duration = duration
        fadeSprite.easeM = easeM
        fadeSprite.modulate.a = startOpacity
        fadeSprite.global_position = copyFrom.global_position
        fadeSprite.global_scale = copyFrom.global_scale
        fadeSprite.global_rotation = copyFrom.global_rotation
        fadeSprite.z_index = z_index
        add_child(fadeSprite)