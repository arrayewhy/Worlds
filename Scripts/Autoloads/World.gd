extends Node;

const CellSize:float = 16;
const Spr_Reg_Size:float = 256;
var MAP_UNIT_WIDTH:int;

var PLAYER_COORD:Vector2;

#signal Initial_MapGen_Complete;

signal Replace_Terrain(idx:int, type:Map_Data.Terrain, spr:Sprite2D);

var _debug:bool;


# Player ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Set_Player_Coord(coord:Vector2, callerPath:String) -> void:
	_Set_Player_Coord(coord);
	if _debug: print("\nWorld.gd - Set_Player_Coord, called by: ", callerPath);

func _Set_Player_Coord(coord:Vector2) -> void:
	PLAYER_COORD = coord;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Replace_Terrain_Sprite(idx:int, type:Map_Data.Terrain, spr:Sprite2D, callerPath:String) -> void:
	if _debug: print("\nWorld.gd - Replace_Terrain_Sprite, called by: ", callerPath);
	Replace_Terrain.emit(idx, type, spr);


# Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Set_Map_Width_In_Units(width:int, callerPath:String) -> void:
	if _debug: print("\nWorld.gd - Set_Map_Width_In_Units, called by: ", callerPath);
	MAP_UNIT_WIDTH = width;


#func Set_TotalUnitWidth(width:float, callerPath:String) -> void:
	#if _debug: print_debug("Set_TotalUnitWidth, called by: ", callerPath);
	#_totalUnitWidth = width;
#
#
#func Total_Unit_Width() -> float:
	#return _totalUnitWidth;
