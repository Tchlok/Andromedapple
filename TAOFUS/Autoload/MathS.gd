extends Node

func Clamp01(input):
	return clamp(input,0,1)
func Truncate(val : float, decimal : int):
	var mult = pow(10,decimal)
	return floor(val * mult)/mult
func Dezimal(f : float):
	return f - floor(f)

#random stuff
func RandVec2(maxLength = 1):
	return Vector2(RandSigned(),RandSigned()) * maxLength
func RandDir2():
	return RandVec2().normalized()
func RandSigned():
	return (randf()-0.5)*2
func Update_V3_Range(input : Vector3):
	input.x=randf_range(input.y,input.z)
	return input

#trig stuff
func VecToRad(vec):
	return atan2(vec.y,vec.x)
func VecToDeg(vec):
	return rad_to_deg(VecToRad(vec))
func RadToVec(rad):
	return Vector2.UP.rotated(rad)
func DegToVec(deg):
	return RadToVec(deg_to_rad(deg))

func Sin01(input):
	return (sin(input)+1)/2


#string stuff
func ToPercent(val):
	return str(floor(val*100)) + "%"

#easing stuff
enum EasingMethod {
	Linear,
	OutSquare,
	OutCubic,
	InSquare,
	InCubic,
	Bounce
}

func Ease(input, method : EasingMethod):
	match method:
		EasingMethod.Linear:
			return EaseLinear(input)
		EasingMethod.OutSquare:
			return EaseOutSquare(input)
		EasingMethod.OutCubic:
			return EaseOutCubic(input)
		EasingMethod.InSquare:
			return EaseInSquare(input)
		EasingMethod.InCubic:
			return EaseInCubic(input)

func EaseLinear(input) : return Clamp01(input)
func EaseOutSquare(input) : return Clamp01(pow(input,0.5))
func EaseOutCubic(input) : return Clamp01(pow(input,0.25))
func EaseInSquare(input) : return Clamp01(pow(input, 2))
func EaseInCubic(input) : return Clamp01(pow(input, 3))

#removes all connections from signal
func ClearSignal(sig):
	var connections : Array = sig.get_connections()
	for con in connections:
		sig.disconnect(con["callable"])

#physics stuff
func RaycastLines(spaceState : PhysicsDirectSpaceState2D, points : Array[Vector2], collisionMask : int, exclude : Array[RID], colArea : bool = true,colBody : bool = true):
	var resultFull : Array[Dictionary]
	for i in points.size()-1:
		var query = PhysicsRayQueryParameters2D.create(points[i],points[i+1],collisionMask,exclude)
		query.collide_with_areas=colArea
		query.collide_with_bodies=colBody
		var result : Dictionary = spaceState.intersect_ray(query)
		resultFull.append(result)
	return resultFull
