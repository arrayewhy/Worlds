class_name GridPos_Utils extends Node;

static func GridPositions_Around(gPos:Vector2i, reach:int, removeCenter:bool = false) -> Array[Vector2i]:
	
	var array:Array[Vector2i] = [];
	var size:int = reach * 2 + 1;
	var topLeft:Vector2i = gPos + Vector2i(-1, -1) * reach;
	var offset:Vector2i = Vector2i(0, 0);
	
	for row in size:
		for col in size:
			var targ:Vector2i = topLeft + offset;
			
			if removeCenter and targ == gPos:
				pass;
			else:
				array.append(targ);
				
			offset.x += 1;
			
		offset.x = 0;
		offset.y += 1;
	
	return array;

static func Empties_Around(gPos:Vector2i, reach:int, removeCenter:bool) -> Array[Vector2i]:
	var surrounding_GPos:Array[Vector2i] = GridPositions_Around(gPos, reach, removeCenter);
	return Remove_Occupied(surrounding_GPos);
	
static func Occupieds_Around(gPos:Vector2i, reach:int, removeCenter:bool) -> Array[Vector2i]:
	var surrounding_GPos:Array[Vector2i] = GridPositions_Around(gPos, reach, removeCenter);
	return Remove_Empty(surrounding_GPos);

static func Are_GridPosNeighbours(gPos:Vector2i, neighbourGPos:Vector2i, diagonal:bool = false) -> bool:
	if gPos + Vector2i.UP == neighbourGPos:
		return true;
	if gPos + Vector2i.DOWN == neighbourGPos:
		return true;
	if gPos + Vector2i.LEFT == neighbourGPos:
		return true;
	if gPos + Vector2i.RIGHT == neighbourGPos:
		return true;
		
	if !diagonal:
		return false;
		
	if gPos + Vector2i(-1, -1) == neighbourGPos:
		return true;
	if gPos + Vector2i(1, -1) == neighbourGPos:
		return true;
	if gPos + Vector2i(-1, 1) == neighbourGPos:
		return true;
	if gPos + Vector2i(1, 1) == neighbourGPos:
		return true;
		
	return false;

# Functions: Removers ----------------------------------------------------------------------------------------------------

static func Remove_Occupied(gPosArray:Array[Vector2i]) -> Array[Vector2i]:
	var empties:Array[Vector2i] = [];
	for gPos in gPosArray:
		if !Biome_Master.Is_Occupied(gPos):
			empties.append(gPos);
	return empties;
	
static func Remove_Empty(gPosArray:Array[Vector2i]) -> Array[Vector2i]:
	var occupied:Array[Vector2i] = [];
	for gPos in gPosArray:
		if Biome_Master.Is_Occupied(gPos):
			occupied.append(gPos);
	return occupied;
