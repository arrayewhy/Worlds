class_name Tools

	
static func Float_OnGrid(val:float) -> float:
	return floor(val / World.CellSize) * World.CellSize;


static func Coord_OnGrid(v2:Vector2) -> Vector2:
	return floor(v2 / World.CellSize) * World.CellSize;


static func V2_Array_Around(pos:Vector2, range:int, skipCenter:bool = false) -> Array[Vector2]:
	
	var p:Array[Vector2] = [];
	
	var width:float = range * 2 + 1;
	
	var start:Vector2 = pos + (-Vector2.ONE * range * World.CellSize);
	
	for y in width:
		for x in width:
			p.append(start + Vector2(x, y) * World.CellSize);
	
	if skipCenter:
		p.remove_at(width * range + range);
	
	return p;
