class_name MenuLine
extends Line2D

var from : MenuLevel
var to : MenuLevel
@export var offset : float
func setup(_from : MenuLevel,_to : MenuLevel):
    from=_from
    to=_to
    set_point_position(0, from.getPos()+from.getPos().direction_to(to.getPos())*offset)
    set_point_position(1, to.getPos()+to.getPos().direction_to(from.getPos())*offset)
    modulate.a = 1.0 if to.levelState==MenuLevel.LevelState.Cleared else 0.25