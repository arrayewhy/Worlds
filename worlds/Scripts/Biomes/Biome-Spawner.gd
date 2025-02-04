extends Node;

@onready var biomePrefab:PackedScene = preload("res://Prefabs/Biomes/Biome.tscn");

@export var biomeHolder:Node;

func _ready() -> void:
	get_parent().SpawnAround.connect(SpawnRandomBiomes_3x3);

# Single Biome

func SpawnBiome(gPos:Vector2i, type:BiomeMaster.Type, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	var newBiome = Instantiate_BiomeNode(type);
	biomeHolder.add_child(newBiome);
	# Position New Biome in World Space
	var newPos:Vector2 = Vector2(gPos) * World.cellSize;
	# Randomise position slightly
	newPos += Vector2(randf_range(-6, 6), randf_range(-6, 6));
	newBiome.position = newPos;
	newBiome.Set_Interaction(interType);
	World.Record_Biome(gPos, newBiome, type, interType);
	# Debug Message
	InGameDebugger.Say(str(gPos, " : ", World.Get_BiomeType(gPos), ", ", World.Get_InteractionType(gPos)), true);
	
func SpawnRandomBiome(gPos:Vector2i, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	SpawnBiome(gPos, BiomeMaster.RandomBiomeType(), interType);
	
func Instantiate_BiomeNode(type:BiomeMaster.Type) -> Node2D:
	var newBiome:Object = biomePrefab.instantiate();
	newBiome.Initialise(type);
	return newBiome;

# Multiple Biomes
	
func SpawnRandomBiomes_3x3(gPos:Vector2i) -> void:
	var surrounding_GPos = Get_GridPosArray3x3(gPos);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = Get_EmptyGridPositions(surrounding_GPos);
	for e in surrounding_GPos:
		SpawnRandomBiome(e);
		#SpawnBiome(e, BiomeMaster.Type.Earth);
	
func Get_GridPosArray3x3(gPos:Vector2i, includeCenter:bool = false) -> Array[Vector2i]:
	var array:Array[Vector2i];
	array.append_array(
		[gPos + Vector2i(-1,-1), # Top Left
		gPos + Vector2i.UP, 
		gPos + Vector2i(1,-1), # Top Right
		gPos + Vector2i.LEFT]
		);
	if includeCenter:
		array.push_back(gPos);
	array.append_array(
		[
		gPos + Vector2i.RIGHT,
		gPos + Vector2i(-1,1), # Bottom Left
		gPos + Vector2i.DOWN, 
		gPos + Vector2i(1,1)] # Bottom Right
		);
	return array;

func Get_EmptyGridPositions(gPosArray:Array[Vector2i]) -> Array[Vector2i]:
	var empties:Array[Vector2i] = [];
	for gPos in gPosArray:
		if !World.Is_Occupied(gPos):
			empties.append(gPos);
	return empties;
	
func Get_OccupiedGridPositions(gPosArray:Array[Vector2i]) -> Array[Vector2i]:
	var occupied:Array[Vector2i] = [];
	for gPos in gPosArray:
		if World.Is_Occupied(gPos):
			occupied.append(gPos);
	return occupied;

func Get_BiomeTypesAround(gPos:Vector2i) -> Array[Array]:
	var surrounding_GPos:Array[Vector2i] = Get_GridPosArray3x3(gPos, true);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = Get_OccupiedGridPositions(surrounding_GPos);
	
	# An Array where each element contains a Grid Pos and Biome Type
	var influences:Array[Array];
	
	for p in surrounding_GPos:
		influences.append([p, World.Get_BiomeType(p)]);
		
	# Debug Message
		
	var message:String;
		
	for i in influences.size():
		if i == 4:
			message += "PLAYER";
		message += str("GridPos: ", influences[i][0], ", Biome: ", influences[i][1], " | ");
		
	InGameDebugger.Say(message);
	
	return influences;
	
func Are_GridPosNeighbours(gPos:Vector2i, neighbourGPos:Vector2i) -> bool:
	if gPos + Vector2i.UP == neighbourGPos:
		return true;
	if gPos + Vector2i.DOWN == neighbourGPos:
		return true;
	if gPos + Vector2i.LEFT == neighbourGPos:
		return true;
	if gPos + Vector2i.RIGHT == neighbourGPos:
		return true;
	return false;
