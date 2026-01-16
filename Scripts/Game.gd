class_name Game
extends Node2D


@export var level : Level
@export var cam : Cam

enum GameState{View,Aim,Track,GameOver}
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
var aimVec : Vector2
var aimDir : Vector2
var savedZoom : float

@export var packedAimVisuals : PackedScene
var aimVisualsInstance : Node2D

@export var packedTreePlaceVisuals : PackedScene
var treePlaceVisualsInstance : TreePlaceVisuals

var mainHeldTime : float
var secondaryHeldTime : float

@export var gameUi : GameUi

func _enter_tree():
	level.EV_LevelSetup.connect(onLevelSetup)
	level.EV_TreeSpawned.connect(onTreeSpawned)
	level.EV_FruitSpawned.connect(onFruitSpawned)
	level.EV_FruitRemoved.connect(onFruitRemoved)
	level.EV_ProjectileSpawned.connect(onProjectileSpawned)
	level.EV_ProjectileRemoved.connect(onProjectileRemoved)

func _ready():
	pass

func _physics_process(delta: float):
	match gameState:
		GameState.View:
			pass
		GameState.Aim:
			pass
		GameState.Track:
			pass

func _process(delta: float):
	level.testLog.display("GameState",gameState)
	level.testLog.display("SubState",subStateIndex)
	
	var  targetTimeScale=1.0
	if gameState!=GameState.GameOver:
		if Input.is_action_pressed("Fast") and not TransitionManager.IsTransitioning():
			targetTimeScale=2.0
		if Input.is_action_pressed("Retry"):
			Persistent.TransitionGame()
	Engine.time_scale=targetTimeScale
	Engine.physics_ticks_per_second=ceili(60*targetTimeScale)
	_stateT+=delta
	var scrollZoomBlocked=false
	match gameState:
		GameState.View:
			if Input.is_action_just_pressed("FruitSelect"):
				cycleSelectedFruit()
			if Input.is_action_just_pressed("Main"):
				if level.fruitsOfTree(selectedTree).size()!=0:
					setGameState(GameState.Aim)
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
			
			var messageRight : String = ""
			if cam.relativeTo==null:
				messageRight+="TAP: FOLLOW PLANET"
			else:
				messageRight+="TAP: END FOLLOW"
			messageRight+="\nHOLD: PAN CAMERA"
			gameUi.updateInputText("AIM FRUIT",messageRight)
		GameState.Aim:
			if Input.is_action_just_pressed("FruitSelect"):
				cycleSelectedFruit()
			aimVec = (get_global_mouse_position()-selectedFruit.global_position)
			aimDir=aimVec.normalized()
			aimVisualsInstance.update(aimVec)
			if Input.is_action_pressed("Secondary"):
				cam.executePanMovement()
			else:
				cam.targetPosition=selectedFruit.global_position-level.planetOfTree(selectedTree).global_position
			if Input.is_action_just_released("Secondary"):
				if secondaryHeldTime<stateReturnThreshold:
					setGameState(GameState.View)
			elif Input.is_action_just_pressed("Main"):
				level.spawnProjectile(selectedFruit, selectedFruit.global_position,aimDir)
			
			gameUi.updateInputText("SHOOT!","TAP: VIEW MAP\nHOLD: PAN CAMERA")
		GameState.Track:
			if subStateIndex==0: #flying
				level.testLog.display("ProjVel", int(selectedProjectile.linear_velocity.length()))
				if Input.is_action_just_released("Secondary"):
					if secondaryHeldTime<stateReturnThreshold:
						level.removeProjectile(selectedProjectile,true)
				
				gameUi.updateInputText("", "DISCARD")
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
						setGameState(GameState.View)
				elif Input.is_action_just_released("Secondary"):
					if secondaryHeldTime<stateReturnThreshold:
						if selectedTreeFruitsRemaining>0:
							treePlaceVisualsInstance.destroy()
							treePlaceVisualsInstance=null
							setGameState(GameState.View)
						else:
							print("can't discard")
				gameUi.updateInputText("PLANT TREE", "DISCARD")
		GameState.GameOver:
			if not TransitionManager.IsTransitioning() and _stateT > 0.5:
				if Input.is_action_just_pressed("Main"):
					Persistent.TransitionMenu()
				elif Input.is_action_just_pressed("Secondary"):
					Persistent.TransitionGame()
			gameUi.updateInputText("TO MENU", "TRY AGAIN")
	
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
				updateFruit(selectedFruit)
			cam.moveRelativeTo(level.planetOfTree(selectedTree))
		GameState.Aim:
			if selectedFruit==null:
				cycleSelectedFruit()
			selectedFruit.setFruitState(Fruit.FruitState.Aiming)
			cam.moveRelativeTo(level.planetOfTree(level.treeOfFruit(selectedFruit)))
			var planet : Planet = level.planetOfTree(selectedTree)
		GameState.Track:
			cam.targetPosition=Vector2.ZERO
			cam.moveRelativeTo(selectedProjectile)
		GameState.GameOver:
			pass
	updateAimVisuals()

func onLevelSetup():
	level.spawnTree(packedTree, level.planets[0], Vector2.ZERO+level.planets[0].radius*Vector2.UP,0)
	setGameState(GameState.View)

func onFruitTreeReady(fruitTree:FruitTree):
	selectedTreeFruitsRemaining=selectedTree.spawnPoints.get_child_count()
	updateFruit(level.fruitsOfTree(selectedTree)[0])

func onTreeSpawned(tree : FruitTree):
	if selectedTree!=tree:
		var dropFruits : Array[Fruit] = level.fruitsOfTree(selectedTree)
		for f : Fruit in dropFruits:
			level.removeFruit(f)
	selectedTree=tree
	tree.EV_FruitTreeReady.connect(onFruitTreeReady)
func onFruitSpawned(fruit : Fruit):
	pass
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

func updateFruit(_selectedFruit : Fruit):
	if selectedFruit!=null and selectedFruit!=_selectedFruit:
		selectedFruit.setFruitState(Fruit.FruitState.Normal)
	selectedFruit=_selectedFruit
	var state : Fruit.FruitState
	if gameState==GameState.Aim:
		state=Fruit.FruitState.Aiming
	else:
		state=Fruit.FruitState.Selected
	selectedFruit.setFruitState(state)
func updateAimVisuals():
	if aimVisualsInstance==null:
		if selectedFruit!=null:
			aimVisualsInstance=packedAimVisuals.instantiate()
			aimVisualsInstance.position=selectedFruit.global_position-level.planetOfFruit(selectedFruit).global_position
			level.planetOfFruit(selectedFruit).add_child(aimVisualsInstance)
	else:
		if gameState!=GameState.Aim:
			aimVisualsInstance.destroy()
			aimVisualsInstance=null
		else: #fruit swap
			aimVisualsInstance.destroy()
			aimVisualsInstance=null
			updateAimVisuals()
func cycleSelectedFruit():
	if selectedTree==null:
		return
	var indexOfFruit : int = 0
	var fruitsOnTree : Array[Fruit] = level.fruitsOfTree(selectedTree)
	if fruitsOnTree.size()==0:
		return
	if selectedFruit!=null:
		for i in range(fruitsOnTree.size()):
			if fruitsOnTree[i]==selectedFruit:
				indexOfFruit=i
				break
		indexOfFruit+=1
		if indexOfFruit>=fruitsOnTree.size():
			indexOfFruit=0
	updateFruit(fruitsOnTree[indexOfFruit])
	updateAimVisuals()
