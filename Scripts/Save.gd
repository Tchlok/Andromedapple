extends Node

const savePath : String = "user://save.txt"

var clearedLevels : Array[Vector2i]
var freshSave : bool

func _enter_tree():
	if not FileAccess.file_exists(savePath):
		print("Starting game for the first time")
		clearedLevels.clear()
		clearedLevels.append(Vector2i.ZERO)
		freshSave=true
		updateSave()
	else:
		var access : FileAccess = FileAccess.open(savePath, FileAccess.READ)
		clearedLevels = access.get_var()
		print("Read save " + str(clearedLevels.size()))
		access.close()

func updateSave():
	var access : FileAccess = FileAccess.open(savePath, FileAccess.WRITE)
	access.store_var(clearedLevels)
	access.close()
