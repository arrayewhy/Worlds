class_name Tools

	
static func Float_OnGrid(val:float) -> float:
	return floor(val / World.CellSize) * World.CellSize;


static func Coord_OnGrid(v2:Vector2) -> Vector2:
	return floor(v2 / World.CellSize) * World.CellSize;


static func Index_To_Coord(idx:int, width:int) -> Vector2:
	return Vector2(idx % width, idx / width);


static func Coord_To_Index(coord:Vector2, width) -> int:
	return (width * coord.y + coord.x) / World.CellSize;


static func V2_Array_Around(pos:Vector2, range:int, skipCenter:bool = false) -> Array[Vector2]:
	
	var p:Array[Vector2] = [];
	
	var length:float = range * 2 + 1;
	
	var start:Vector2 = pos + (-Vector2.ONE * range * World.CellSize);
	#REFACTOR
	for y in length:
		
		if start.y + y * World.CellSize < 0 || start.y + y * World.CellSize >= World.MapWidth() * World.CellSize:
			continue;
		
		for x in length:
			
			if start.x + x * World.CellSize < 0 || start.x + x * World.CellSize >= World.MapWidth() * World.CellSize:
				continue;
			p.append(start + Vector2(x, y) * World.CellSize);
	
	if skipCenter && p.has(pos):
		p.erase(pos);
		#p.remove_at(length * range + range);
	
	return p;
