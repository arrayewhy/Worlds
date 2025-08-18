extends Node;

var CellSize:float = 16;
var Spr_Reg_Size:float = 256;
var _mapWidth:float;

signal Initial_MapGen_Complete;

var _debug:bool;


func Signal_Initial_MapGen_Complete(callerPath:String) -> void:
	if _debug: print_debug("Signal_Initial_MapGen_Complete, called by: ", callerPath);
	Initial_MapGen_Complete.emit();


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Set_MapWidth(width:float, callerPath:String) -> void:
	if _debug: print_debug("Set_MapWidth, called by: ", callerPath);
	_mapWidth = width;


func MapWidth() -> float:
	return _mapWidth;


#func Set_TotalUnitWidth(width:float, callerPath:String) -> void:
	#if _debug: print_debug("Set_TotalUnitWidth, called by: ", callerPath);
	#_totalUnitWidth = width;
#
#
#func Total_Unit_Width() -> float:
	#return _totalUnitWidth;
