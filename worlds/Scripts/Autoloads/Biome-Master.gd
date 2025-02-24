class_name Biome_Master extends Node;

enum Type {NULL, Earth, Grass, Water};

static func RandomBiomeType() -> int:
	# Return an Int instead of a Type since this is faster.
	# If this doesn't suffice, do a Match and return the appropriate Type as a String.
	return randi_range(1, Type.keys().size() - 1);

# Functions: Biomes ----------------------------------------------------------------------------------------------------

static func Record_Biome(gPos:Vector2i, biome:Object, type:Biome_Master.Type, discBiomes:Dictionary = World.DiscoveredBiomes()) -> void:
	discBiomes[gPos] = [biome, type];

static func Is_Occupied(gPos:Vector2i, discBiomes:Dictionary = World.DiscoveredBiomes()) -> bool:
	return discBiomes.has(gPos);

static func Get_BiomeObject(gPos:Vector2i, discBiomes:Dictionary = World.DiscoveredBiomes()) -> Object:
	
	if discBiomes.has(gPos):
		return discBiomes[gPos][0];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return null;

static func Get_BiomeType(gPos:Vector2i, discBiomes:Dictionary = World.DiscoveredBiomes()) -> Biome_Master.Type:
	
	if discBiomes.has(gPos):
		return discBiomes[gPos][1];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return Biome_Master.Type.NULL;

static func Surrounding_Biomes(gPos:Vector2i, reach:int) -> Array[Biome_Master.Type]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Remove_Empty(surrounding_GPos);
	
	var biomesAround:Array[Biome_Master.Type]; # Array[Biome Type]
	
	for p in surrounding_GPos:
		biomesAround.append(World.Get_BiomeType(p));
	
	return biomesAround;

static func Surrounding_Biomes_WithGPos(gPos:Vector2i, reach:int) -> Array[Array]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Remove_Empty(surrounding_GPos);
	
	var biomesAround:Array[Array]; # Array[Grid Pos, Biome Type]
	
	for p in surrounding_GPos:
		biomesAround.append([p, Biome_Master.Get_BiomeType(p)]);
	
	return biomesAround;
