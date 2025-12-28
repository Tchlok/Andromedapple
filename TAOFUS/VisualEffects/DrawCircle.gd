class_name DrawCircle
extends Line2D

@export var _radius : float = 40
func Radius(newRad=null):
	if newRad != null:
		_radius = newRad
		_UpdateCircle()
	return _radius

@export_range(0,1) var _fill : float = 1
func Fill(newFill=null):
	if newFill != null:
		_fill = newFill
		_UpdateCircle()
	return _fill

@export var _pointCount : int = 32
func PointCount(newPointCount=null):
	if newPointCount == not null:
		_pointCount=newPointCount
		_UpdateCircle()
	return _pointCount

@export var _squash : float = 1
func Squash(newSquash=null):
	if newSquash == not null:
		_squash=newSquash
		_UpdateCircle()
	return _squash

func _enter_tree():
	_UpdateCircle()

func _UpdateCircle():
	var finalCount = floori(_pointCount*_fill)
	var newPoints : Array[Vector2]
	
	for i in finalCount:
		var vec = MathS.DegToVec(float(i) / float(_pointCount) * 360)
		newPoints.append(vec*_radius*Vector2(1,_squash))
	
	if finalCount ==_pointCount: #close circle
		newPoints.append(newPoints[0])
	points=newPoints
