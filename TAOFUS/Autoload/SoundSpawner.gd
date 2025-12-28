extends Node

const SoundPlayerPath = "res://Library/SoundPlayer.tscn"
const SoundPlayerPath2D = "res://Library/SoundPlayer2D.tscn"
const SoundsPath = "res://Sounds/"
const SoundsPrefix = "Sound"

func _enter_tree():
	process_mode = Node.PROCESS_MODE_ALWAYS

func SpawnFromName(soundName : String, pitchVariance : float = 0, position = null):
	var stream : AudioStream = load(SoundsPath+SoundsPrefix+soundName+".mp3")
	return SpawnFromStream(stream, pitchVariance, position)

func SpawnFromStream(stream : AudioStream, pitchVariance : float = 0, position = null):
	#choose AudioStreamPlayer type
	var playerPath = SoundPlayerPath2D if position is Vector2 else SoundPlayerPath
	var player : AudioStreamPlayer = load(playerPath).instantiate()
	
	player.pitch_scale += randf() * pitchVariance
	player.stream = stream
	player.connect("finished", player.queue_free) #sound frees itself after it finishes
	add_child(player)
	return player
