class_name Tools
	
static func Float_OnGrid(val:float, cellSize:float) -> float:
	return floor(val / cellSize) * cellSize;

static func Coord_OnGrid(v2:Vector2, cellSize:float) -> Vector2:
	return floor(v2 / cellSize) * cellSize;
