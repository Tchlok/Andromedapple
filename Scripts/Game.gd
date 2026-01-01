class_name Game
extends Node2D

@export var level : Level
@export var cam : Cam

enum GameState{View,Select,Aim,Track}
var gameState : GameState
var subStateIndex : int
var _stateT : float

@export var packedTree : PackedScene

var selectedTree : FruitTree
var selectedFruit : Fruit
var selectedProjectile : Projectile
@export var stateReturnThreshold : float

@export var aimDistanceLimit : float
@export var aimBaseSpeedLimit : float
var aimDir : Vector2
var aimP : float
var aimCurSpeed : float

@export var packedAimVisuals : PackedScene
var aimVisualsInstance : Node2D

var mainHeldTime : float
var secondaryHeldTime : float


func _enter_tree():
	level.EV_LevelSetup.connect(onLevelSetup)
	level.EV_TreeSpawned.connect(onTreeSpawned)
	level.EV_FruitSpawned.connect(onFruitSpawned)
	level.EV_ProjectileSpawned.connect(onProjectileSpawned)
	gameState = GameState.Select

func _ready():
	pass

func _physics_process(delta: float):
	match gameState:
		GameState.View:
			pass
		GameState.Select:
			pass
		GameState.Aim:
			pass
		GameState.Track:
			pass

func _process(delta: float):
	level.testLog.display("GameState",gameState)
	level.testLog.display("SubState",subStateIndex)

	_stateT+=delta
	var scrollZoomBlocked=false
	match gameState:
		GameState.View:
			if Input.is_action_just_pressed("Main"):
				setGameState(GameState.Select)
			elif Input.is_action_just_released("Secondary"):
				if secondaryHeldTime<stateReturnThreshold:
					if cam.relativeTo==null:
						cam.targetPosition=selectedTree.position
						cam.moveRelativeTo(level.planetOfTree(selectedTree))
					else:
						cam.targetPosition=cam.position
						cam.moveRelativeTo(null)
			elif Input.is_action_pressed("Secondary"):
				cam.executePanMovement()
		GameState.Select:
			scrollZoomBlocked=true
			if subStateIndex==0:
				if cam.distanceToTarget()<100:
					cam.fullZoomIn()
					subStateIndex=1
			else:
				if Input.is_action_just_pressed("Main"):
					if selectedFruit!=null:
						setGameState(GameState.Aim)
					else:
						print("No fruit selected")
				elif Input.is_action_just_released("Secondary"):
					if secondaryHeldTime<stateReturnThreshold:
						setGameState(GameState.View)
						cam.stepZoomOut()
		GameState.Aim:
			var aimVec : Vector2 = (get_global_mouse_position()-selectedFruit.global_position).limit_length(aimDistanceLimit)
			aimDir=aimVec.normalized()
			aimP=aimVec.length()/aimDistanceLimit
			aimCurSpeed=aimP*aimBaseSpeedLimit
			aimVisualsInstance.update(aimVec,aimP)

			if Input.is_action_pressed("Secondary"):
				cam.executePanMovement()
			else:
				cam.targetPosition=selectedFruit.position
			
			if Input.is_action_just_released("Secondary"):
				if secondaryHeldTime<stateReturnThreshold:
					setGameState(GameState.Select)
			elif Input.is_action_just_pressed("Main"):
				level.spawnProjectile(selectedFruit, selectedFruit.global_position,-aimDir,aimCurSpeed)
			
		GameState.Track:
			pass
	
	if not scrollZoomBlocked:
		if Input.is_action_just_pressed("ZoomIn"):
			cam.stepZoomIn()
		if Input.is_action_just_pressed("ZoomOut"):
			cam.stepZoomOut()

	if Input.is_action_pressed("Main"):
		mainHeldTime+=delta
	else:
		mainHeldTime=0
	if Input.is_action_pressed("Secondary"):
		secondaryHeldTime+=delta
	else:
		secondaryHeldTime=0

func setGameState(newState : GameState):
	var oldState : GameState = gameState
	gameState=newState
	_stateT=0
	subStateIndex=0
	match gameState:
		GameState.View:
			if selectedFruit!=null:
				selectedFruit.setFruitState(Fruit.FruitState.Normal)
				selectedFruit=null
			level.fruitMouseEvents(false)
			cam.moveRelativeTo(level.planetOfTree(selectedTree))
		GameState.Select:
			if aimVisualsInstance!=null:
				aimVisualsInstance.destroy()
				aimVisualsInstance=null
			if selectedFruit!=null:
				selectedFruit.setFruitState(Fruit.FruitState.Normal)
				selectedFruit=null
			level.fruitMouseEvents(true)
			cam.moveRelativeTo(level.planetOfTree(selectedTree))
			cam.targetPosition=selectedTree.position
		GameState.Aim:
			selectedFruit.setFruitState(Fruit.FruitState.Aiming)
			level.fruitMouseEvents(false)
			cam.moveRelativeTo(level.planetOfTree(selectedTree))
			cam.targetPosition=selectedFruit.position+selectedTree.position
			var planet : Planet = level.planetOfTree(selectedTree)
			aimVisualsInstance=packedAimVisuals.instantiate()
			aimVisualsInstance.position=selectedFruit.global_position-planet.global_position
			planet.add_child(aimVisualsInstance)
			
		GameState.Track:
			if aimVisualsInstance!=null:
				aimVisualsInstance.destroy()
				aimVisualsInstance=null
			
			level.removeFruit(selectedFruit)
			selectedFruit=null
			
			level.fruitMouseEvents(false)
			cam.targetPosition=Vector2.ZERO
			cam.moveRelativeTo(selectedProjectile)

func onLevelSetup():
	level.spawnTree(packedTree, level.planets[0], Vector2.ZERO)
	setGameState(GameState.View)

func onTreeSpawned(tree : FruitTree):
	selectedTree=tree
func onFruitSpawned(fruit : Fruit):
	fruit.EV_enter.connect(onFruitEnter)
	fruit.EV_exit.connect(onFruitExit)
func onProjectileSpawned(projectile):
	selectedProjectile=projectile
	setGameState(GameState.Track)


func onFruitEnter(fruit : Fruit):
	if gameState!=GameState.Select:
		return
	selectedFruit=fruit
	selectedFruit.setFruitState(Fruit.FruitState.Selected)
func onFruitExit(fruit : Fruit):
	if gameState!=GameState.Select:
		return
	if selectedFruit==fruit:
		selectedFruit.setFruitState(Fruit.FruitState.Normal)
		selectedFruit=null
