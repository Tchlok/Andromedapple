class_name TestLog
extends Node2D

@export var cam : Camera2D
@export var label : RichTextLabel
var text : String

func _enter_tree():
	visible=false

func _process(delta):
	label.text=text
	scale=Vector2.ONE/cam.zoom.x
	text=""
	if Input.is_action_just_pressed("TestLogToggle"):
		visible=not visible

func display(name : String, value):
	text+=name + ": " + str(value) + "\n"
