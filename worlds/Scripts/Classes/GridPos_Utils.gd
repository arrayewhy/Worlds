class_name GridPos_Utils extends Node;

static func GridPositions_Around(gPos:Vector2i, reach:int) -> Array[Vector2i]:
	
	var array:Array[Vector2i] = [];
	
	var size:int = reach * 2 + 1;
	
	var topLeft:Vector2i = gPos + Vector2i(-1, -1) * reach;
	
	var offset:Vector2i = Vector2i(0, 0);
	
	for row in size:
		for col in size:
			array.append(topLeft + offset);
			offset.x += 1;
		offset.x = 0;
		offset.y += 1;
	
	return array;

static func Get_Surrounding_Empties(gPos:Vector2i, reach:int) -> Array[Vector2i]:
	var surrounding_GPos:Array[Vector2i] = GridPositions_Around(gPos, reach);
	# The comment below seems wrong?
	# Remove Empty Positions in case we are at the World Edge
	return Remove_Occupied(surrounding_GPos);

static func Remove_Occupied(gPosArray:Array[Vector2i]) -> Array[Vector2i]:
	var empties:Array[Vector2i] = [];
	for gPos in gPosArray:
		if !World.Is_Occupied(gPos):
			empties.append(gPos);
	return empties;
	
static func Get_Occupied(gPosArray:Array[Vector2i]) -> Array[Vector2i]:
	var occupied:Array[Vector2i] = [];
	for gPos in gPosArray:
		if World.Is_Occupied(gPos):
			occupied.append(gPos);
	return occupied;

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
