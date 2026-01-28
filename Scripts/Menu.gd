class_name Menu
extends Node2D

@export var worldHolder : Node2D
var clearedLevels : Array[MenuLevel]
var unlockedLevels : Array[MenuLevel]
@export var linePacked : PackedScene
@export var controlBlock : Control

func _ready():
	controlBlock.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var cur : MenuLevel
	for cord : Vector2i in Save.clearedLevels:
		cur = getLevelFromCord(cord)
		if cur!=null:
			cur.activate(self,cord,true)
			clearedLevels.append(cur)
	
	if not Save.clearedLevels.has(Vector2i.ZERO):
		var startLevel : MenuLevel = getLevelFromCord(Vector2i.ZERO)
		startLevel.activate(self,Vector2.ZERO,false)

	for c : MenuLevel in clearedLevels:
		for u : MenuLevel in c.unlocks:
			if u == null:
				continue
			if not unlockedLevels.has(u) and not clearedLevels.has(u):
				unlockedLevels.append(u)
	for u : MenuLevel in unlockedLevels:
		u.activate(self,getCordsFromLevel(u),false)


	# spawn lines
	var line : MenuLine
	for c : MenuLevel in clearedLevels:
		for u : MenuLevel in c.unlocks:
			if u == null:
				continue
			if u.cord.x!=c.cord.x: # different worlds
				continue
			line=linePacked.instantiate()
			add_child(line)
			line.setup(c,u)


func _process(delta):
	if TransitionManager.IsTransitioning():
		return
	if Input.is_action_just_pressed("Main") and focusedLevel!=null:
		Persistent.layoutCords=focusedLevel.cord
		Persistent.layoutPacked=focusedLevel.layout
		Persistent.TransitionGame()

func getCordsFromLevel(level : MenuLevel):
	var result : Vector2i
	var i : int = 0
	for c in level.get_parent().get_children(): #index within world
		if c is MenuLevel:
			if c==level:
				break
			i+=1
	result.y=i
	i=0
	for c in level.get_parent().get_parent().get_children(): #index of world
		if c is MenuWorld:
			if c==level.get_parent():
				break
			i+=1
	result.x=i
	return result

func getLevelFromCord(cord : Vector2i):
	var w : MenuWorld = getWorldFromIdx(cord.x)
	if w==null:
		return null
	var i : int = 0
	for c in w.get_children():
		if c is MenuLevel:
			if i==cord.y:
				return c
			i+=1

func getWorldFromIdx(idx : int):
	var i : int = 0
	for c in worldHolder.get_children():
		if c is MenuWorld:
			if i==idx:
				return c
			i+=1
	return null

var focusedLevel : MenuLevel
func onMouseEntered(worldLevel : MenuLevel):
	focusedLevel=worldLevel
func onMouseExited(worldLevel : MenuLevel):
	focusedLevel=null
