class_name InputGuide
extends Node2D

func _enter_tree():
    pass
@export var label : RichTextLabel
func update(newText : String):
    if "[center]"+label.text==newText:
        return
    label.size.y=0
    label.text="[center]"+newText
    label.position.y=-(label.size.y/2)