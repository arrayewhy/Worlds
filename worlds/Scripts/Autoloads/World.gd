extends Node;

const CellSize:float = 16;
const Spr_Reg_Size:float = 256;
var _mapWidth:int;

signal Initial_MapGen_Complete;

var _debug:bool;


func Signal_Initial_MapGen_Complete(callerPath:String) -> void:
	if _debug: print_debug("Signal_Initial_MapGen_Complete, called by: ", callerPath);
	Initial_MapGen_Complete.emit();


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Set_MapWidth(width:int, callerPath:String) -> void:
	if _debug: print_debug("Set_MapWidth, called by: ", callerPath);
	_mapWidth = width;


func MapWidth() -> int:
	return _mapWidth;


#func Set_TotalUnitWidth(width:float, callerPath:String) -> void:
	#if _debug: print_debug("Set_TotalUnitWidth, called by: ", callerPath);
	#_totalUnitWidth = width;
#
#
#func Total_Unit_Width() -> float:
	#return _totalUnitWidth;


func Float_OnGrid(val:float) -> float:
	return floor(val / CellSize) * CellSize;


func Coord_OnGrid(v2:Vector2) -> Vector2:
	return floor(v2 / CellSize) * CellSize;


func Index_To_Coord(idx:int) -> Vector2:
	return Vector2(idx % int(_mapWidth), idx / _mapWidth) * CellSize;


func Coord_To_Index(coord:Vector2) -> int:
	return (_mapWidth * coord.y + coord.x) / CellSize;


func V2_Array_Around(pos:Vector2, range:int, skipCenter:bool = false) -> Array[Vector2]:
	
	var p:Array[Vector2] = [];
	
	var length:float = range * 2 + 1;
	
	var start:Vector2 = pos + (-Vector2.ONE * range * CellSize);
	#REFACTOR
	for y in length:
		
		if start.y + y * CellSize < 0 || start.y + y * CellSize >= _mapWidth * CellSize:
			continue;
		
		for x in length:
			
			if start.x + x * CellSize < 0 || start.x + x * CellSize >= _mapWidth * CellSize:
				continue;
			p.append(start + Vector2(x, y) * CellSize);
	
	if skipCenter && p.has(pos):
		p.erase(pos);
		#p.remove_at(length * range + range);
	
	return p;
