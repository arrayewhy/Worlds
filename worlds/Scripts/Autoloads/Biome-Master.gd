class_name Biome_Master extends Node;

enum Type {NULL, DARKNESS, Grass, Water, Earth, Stone};
enum Predefined {NULL, Cavern};

const biomePrefab:PackedScene = preload("res://Prefabs/Biome.tscn");

static func RandomBiomeType_Core() -> int:
	
	# 1. Return an Int instead of a Type since this is faster.
	# If this doesn't suffice, do a Match and return the appropriate Type as a String.
	
	# 2. We treat Grass, Earth, and Water as core biomes.
	
	return randi_range(2, 4);
	
static func RandomBiomeType_Land() -> int:
	# Return an Int instead of a Type since this is faster.
	# If this doesn't suffice, do a Match and return the appropriate Type as a String.
	var types = Type.keys();
	types.erase(Type.keys()[Type.Water]);
	#print(types);
	return randi_range(2, types.size() - 2);

# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

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

static func Surrounding_Biomes(gPos:Vector2i, reach:int, removeCent:bool, includeDark:bool) -> Array[Biome_Master.Type]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach, removeCent);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Remove_Empty(surrounding_GPos);
	
	var biomesAround:Array[Biome_Master.Type]; # Array[Biome Type]
	
	for gp in surrounding_GPos:
		var currType:Biome_Master.Type = Biome_Master.Get_BiomeType(gp);
		if !includeDark and currType == Biome_Master.Type.DARKNESS:
			continue;
		biomesAround.append(currType);
	
	return biomesAround;

static func Surrounding_Biomes_WithGPos(gPos:Vector2i, reach:int, includeDark:bool) -> Array[Array]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Remove_Empty(surrounding_GPos);
	
	var biomesAround:Array[Array]; # Array[Grid Pos, Biome Type]
	
	for gp in surrounding_GPos:
		var currType:Biome_Master.Type = Biome_Master.Get_BiomeType(gp);
		if !includeDark and currType == Biome_Master.Type.DARKNESS:
			continue;
		biomesAround.append([gp, currType]);
	
	return biomesAround;

static func SpawnBiome(gPos:Vector2i, type:Biome_Master.Type, holder:Node, \
interType:Interaction_Master.Type, posOffset:Vector2 = Vector2.ZERO) -> void:
	
	var newBiome:Object = biomePrefab.instantiate();
	newBiome.Initialise(gPos, type);
	holder.add_child(newBiome);
	
	# Position New Biome in World Space
	newBiome.position = Vector2(gPos) * World.CellSize() + posOffset;
	
	# Record the biome
	Record_Biome(gPos, newBiome, type);
	
	newBiome.Initialise_Interaction(type, interType);
	
	World.IncreaseWorldSize();

	# We do this check through the holder because neither Biome.gd nor Biome-Master can access the Scene Tree.
	#await holder.get_tree().process_frame
	#newBiome.Check_Surroundings();
