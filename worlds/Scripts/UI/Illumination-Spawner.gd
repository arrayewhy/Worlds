extends Node;

@export var illum:PackedScene;

const limitTop:float = 24;
const limitBtm:float = 1056;
const limitLeft:float = 24;
const limitRight:float = 1896;

const offset:float = 64.5;

var currSpawnPoint := Vector2(limitLeft, limitTop);
var dir := Vector2(1, 0);

func _ready() -> void:
	
	for i in 90:
		var newIllum = illum.instantiate();
		add_child(newIllum);
		newIllum.position = currSpawnPoint;
		
		if CloseTo_Top(newIllum.position.y):
			newIllum.Set_Dir(Vector2(1, 0));
		elif CloseTo_Right(newIllum.position.x):
			newIllum.Set_Dir(Vector2(0, 1));
		elif CloseTo_Bottom(newIllum.position.y):
			newIllum.Set_Dir(Vector2(-1, 0));
		elif CloseTo_Left(newIllum.position.x):
			newIllum.Set_Dir(Vector2(0, -1));
			
		newIllum.Start();
		
		var nextPoint = currSpawnPoint + dir * offset;
		
		if dir == Vector2(1, 0) and nextPoint.x > limitRight:
			dir = Vector2(0, 1);
			currSpawnPoint += dir * offset;
			continue;
		if dir == Vector2(0, 1) and nextPoint.y > limitBtm:
			dir = Vector2(-1, 0);
			currSpawnPoint += dir * offset;
			continue;
		if dir == Vector2(-1, 0) and nextPoint.x < limitLeft:
			dir = Vector2(0, -1);
			currSpawnPoint += dir * offset;
			continue;
		if dir == Vector2(0, -1) and nextPoint.y < limitTop:
			dir = Vector2(1, 0);
			currSpawnPoint += dir * offset;
			continue;
			
		currSpawnPoint = nextPoint;

func CloseTo_Top(y:float) -> bool:
	return Dist_Top(y) < 2;
	
func CloseTo_Bottom(y:float) -> bool:
	return Dist_Btm(y) < 2;
	
func CloseTo_Left(x:float) -> bool:
	return Dist_Left(x) < 2;
	
func CloseTo_Right(x:float) -> bool:
	return Dist_Right(x) < 2;


func Dist_Top(y:float) -> float:
	return abs(limitTop - y);
	
func Dist_Btm(y:float) -> float:
	return abs(limitBtm - y);

func Dist_Left(x:float) -> float:
	return abs(limitLeft - x);
	
func Dist_Right(x:float) -> float:
	return abs(limitRight - x);
