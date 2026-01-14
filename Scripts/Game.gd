class_name Game
extends Node2D

@export var level : Level
@export var cam : Cam

enum GameState{View,Select,Aim,Track,GameOver}
var gameState : GameState
var subStateIndex : int
var _stateT : float

@export var packedTree : PackedScene

var selectedTree : FruitTree
var selectedFruit : Fruit
var selectedProjectile : Projectile
var selectedPlanet : Planet
@export var stateReturnThreshold : float

var selectedTreeFruitsRemaining : int


@export var aimDistanceLimit : float
var aimDir : Vector2
var aimP : float
var savedZoom : float

@export var packedAimVisuals : PackedScene
var aimVisualsInstance : Node2D

@export var packedTreePlaceVisuals : PackedScene
var treePlaceVisualsInstance : TreePlaceVisuals

var mainHeldTime : float
var secondaryHeldTime : float


func _enter_tree():
	level.EV_LevelSetup.connect(onLevelSetup)
	level.EV_TreeSpawned.connect(onTreeSpawned)
	level.EV_FruitSpawned.connect(onFruitSpawned)
	level.EV_FruitRemoved.connect(onFruitRemoved)
	level.EV_ProjectileSpawned.connect(onProjectileSpawned)
	level.EV_ProjectileRemoved.connect(onProjectileRemoved)
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

	var  targetTimeScale=1.0
	if gameState!=GameState.GameOver:
		if Input.is_action_pressed("Fast") and not TransitionManager.IsTransitioning():
			targetTimeScale=2.0
		if Input.is_action_pressed("Retry"):
			Persistent.TransitionGame()
	Engine.time_scale=targetTimeScale
	Engine.physics_ticks_per_second=ceili(60*targetTimeScale)

	level.testLog.display("GameState",gameState)
	level.testLog.display("SubState",subStateIndex)
	level.testLog.display("CamOffset",cam.targetPosition)
	level.testLog.display("Occupy",level.getOccupationP())


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
						cam.setZoomT(savedZoom)
					else:
						print("No fruit selected")
				elif Input.is_action_just_released("Secondary"):
					if secondaryHeldTime<stateReturnThreshold:
						setGameState(GameState.View)
						cam.setZoomT(savedZoom)
		GameState.Aim:
			var aimVec : Vector2 = (get_global_mouse_position()-selectedFruit.global_position).limit_length(aimDistanceLimit)
			aimDir=aimVec.normalized()
			aimP=aimVec.length()/aimDistanceLimit
			aimVisualsInstance.update(aimVec,aimP)

			if Input.is_action_pressed("Secondary"):
				cam.executePanMovement()
			else:
				cam.targetPosition=selectedFruit.global_position-level.planetOfTree(selectedTree).global_position
			
			if Input.is_action_just_released("Secondary"):
				if secondaryHeldTime<stateReturnThreshold:
					setGameState(GameState.Select)
			elif Input.is_action_just_pressed("Main"):
				level.spawnProjectile(selectedFruit, selectedFruit.global_position,aimDir,aimP)
			
		GameState.Track:
			if subStateIndex==0: #flying
				level.testLog.display("ProjVel", int(selectedProjectile.linear_velocity.length()))
				if Input.is_action_just_released("Secondary"):
					if secondaryHeldTime<stateReturnThreshold:
						level.removeProjectile(selectedProjectile,true)
			else: #planting
				var dir : Vector2 = selectedPlanet.global_position.direction_to(get_global_mouse_position())
				treePlaceVisualsInstance.update(dir,selectedPlanet.radius)
				if Input.is_action_just_pressed("Main"):
					level.spawnTree(packedTree,selectedPlanet,dir*selectedPlanet.radius, MathS.VecToDeg(dir)+90)
					treePlaceVisualsInstance.destroy()
					treePlaceVisualsInstance=null
					if level.getOccupationP()==1:
						setGameState(GameState.GameOver)
					else:
						setGameState(GameState.Select)
				elif Input.is_action_just_released("Secondary"):
					if secondaryHeldTime<stateReturnThreshold:
						if selectedTreeFruitsRemaining>0:
							treePlaceVisualsInstance.destroy()
							treePlaceVisualsInstance=null
							setGameState(GameState.View)
						else:
							print("can't discard")
							
		GameState.GameOver:
			if not TransitionManager.IsTransitioning() and _stateT > 0.5:
				if Input.is_action_just_pressed("Main"):
					Persistent.TransitionMenu()
				elif Input.is_action_just_pressed("Secondary"):
					Persistent.TransitionGame()
	
	if not scrollZoomBlocked:
		if Input.is_action_just_pressed("ZoomIn"):
			cam.stepZoomIn()
			savedZoom=cam._zoomT
		if Input.is_action_just_pressed("ZoomOut"):
			cam.stepZoomOut()
			savedZoom=cam._zoomT

	if Input.is_action_pressed("Main"):
		mainHeldTime+=delta
	else:
		mainHeldTime=0
	if Input.is_action_pressed("Secondary"):
		secondaryHeldTime+=delta
	else:
		secondaryHeldTime=0

	if Input.is_action_just_pressed("Menu"):
		Persistent.TransitionMenu()

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
			cam.targetPosition=selectedTree.position+(level.planetOfTree(selectedTree).global_position.direction_to(selectedTree.global_position))*selectedTree.cameraHeight
		GameState.Aim:
			selectedFruit.setFruitState(Fruit.FruitState.Aiming)
			level.fruitMouseEvents(false)
			cam.moveRelativeTo(level.planetOfTree(level.treeOfFruit(selectedFruit)))
			var planet : Planet = level.planetOfTree(selectedTree)
			aimVisualsInstance=packedAimVisuals.instantiate()
			aimVisualsInstance.position=selectedFruit.global_position-planet.global_position
			planet.add_child(aimVisualsInstance)
			
		GameState.Track:
			if aimVisualsInstance!=null:
				aimVisualsInstance.destroy()
				aimVisualsInstance=null
			
			level.fruitMouseEvents(false)
			cam.targetPosition=Vector2.ZERO
			cam.moveRelativeTo(selectedProjectile)
		GameState.GameOver:
			pass

func onLevelSetup():
	level.spawnTree(packedTree, level.planets[0], Vector2.ZERO+level.planets[0].radius*Vector2.UP,0)
	setGameState(GameState.View)

func onTreeSpawned(tree : FruitTree):
	if selectedTree!=tree:
		var dropFruits : Array[Fruit] = level.fruitsOfTree(selectedTree)
		for f : Fruit in dropFruits:
			level.removeFruit(f)
	selectedTree=tree
	selectedTreeFruitsRemaining=selectedTree.spawnPoints.get_child_count()
func onFruitSpawned(fruit : Fruit):
	fruit.EV_enter.connect(onFruitEnter)
	fruit.EV_exit.connect(onFruitExit)
func onFruitRemoved(fruit : Fruit):
	if level.treeOfFruit(fruit)==selectedTree:
		selectedTreeFruitsRemaining=level.fruitsOfTree(selectedTree).size()
func onProjectileSpawned(projectile:Projectile):
	selectedProjectile=projectile
	level.removeFruit(selectedFruit)
	selectedFruit=null
	setGameState(GameState.Track)
func onProjectileRemoved(projectile:Projectile,destroyed:bool,other:Node2D):
	if destroyed:
		subStateIndex=2
		var remainingFruits : Array[Fruit] = level.fruitsOfTree(selectedTree)
		if remainingFruits.size()==0:
			setGameState(GameState.GameOver)
		else:
			setGameState(GameState.View)
	else: #hit planet
		selectedPlanet=other
		cam.relativeTo=selectedPlanet
		cam.targetPosition=Vector2.ZERO
		subStateIndex=1
		treePlaceVisualsInstance=packedTreePlaceVisuals.instantiate()
		treePlaceVisualsInstance.position=Vector2.ZERO
		selectedPlanet.add_child(treePlaceVisualsInstance)

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
