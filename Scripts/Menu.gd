extends Node2D


@export var testLabel : RichTextLabel
@export var testLevels : Array[PackedScene]
var testIdx : int

func _process(delta):
	if not TransitionManager.IsTransitioning():
		if Input.is_action_just_pressed("Main"):
			Persistent.layoutPacked=testLevels[testIdx]
			Persistent.TransitionGame()
		elif Input.is_action_just_pressed("Secondary"):
			testIdx+=1
			if testIdx>=testLevels.size():
				testIdx=0
	testLabel.text="[center]"+str(testIdx)
