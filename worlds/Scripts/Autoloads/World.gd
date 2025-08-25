extends Node;

const CellSize:float = 16;
const Spr_Reg_Size:float = 256;
var _mapWidth:int;

signal Initial_MapGen_Complete;

var _debug:bool;


func Signal_Initial_MapGen_Complete(callerPath:String) -> void:
	if _debug: print("\nWorld.gd - Signal_Initial_MapGen_Complete, called by: ", callerPath);
	Initial_MapGen_Complete.emit();


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Set_MapWidth_In_Units(width:int, callerPath:String) -> void:
	if _debug: print("\nWorld.gd - Set_MapWidth_In_Units, called by: ", callerPath);
	_mapWidth = width;


func MapWidth_In_Units() -> int:
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
	return round(v2 / CellSize) * CellSize;
	#return floor(v2 / CellSize) * CellSize;


func Convert_Index_To_Coord(idx:int) -> Vector2:
	return Vector2(idx % int(_mapWidth), idx / _mapWidth) * CellSize;


func Convert_Coord_To_Index(coord:Vector2) -> int:
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


func Convert_CoordArray_To_IdxArray(coordArray:Array[Vector2]) -> Array[int]:
	var idx_array:Array[int];
	for coord in coordArray:
		var idx:int = int((_mapWidth * coord.y + coord.x) / CellSize);
		idx_array.push_back(idx);
	return idx_array;


func Terrain_Is_Land(terrain:Map_Data.Terrain) -> bool:
	if terrain == Map_Data.Terrain.MOUNTAIN \
	|| terrain == Map_Data.Terrain.FOREST \
	|| terrain == Map_Data.Terrain.GROUND \
	|| terrain == Map_Data.Terrain.SHORE \
	|| terrain == Map_Data.Terrain.TEMPLE_BROWN \
	|| terrain == Map_Data.Terrain.DOCK:
		return true;
	return false;
