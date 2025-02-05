extends Node;

@onready var biomePrefab:PackedScene = preload("res://Prefabs/Biomes/Biome.tscn");

@export var biomeHolder:Node;

func _ready() -> void:
	get_parent().SpawnAround.connect(SpawnRandomBiomes_3x3_Influenced);

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
	World.Check_IncreaseWorldSize();
	# Debug Message
	#InGameDebugger.Say(str(gPos, " : ", World.Get_BiomeType(gPos), ", ", World.Get_InteractionType(gPos)), true);
	
func SpawnRandomBiome(gPos:Vector2i, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	SpawnBiome(gPos, BiomeMaster.RandomBiomeType(), interType);
	
func Instantiate_BiomeNode(type:BiomeMaster.Type) -> Node2D:
	var newBiome:Object = biomePrefab.instantiate();
	newBiome.Initialise(type);
	return newBiome;

# Multiple Biomes
	
func SpawnRandomBiomes_3x3(gPos:Vector2i) -> void:
	var empties:Array[Vector2i] = Get_SurroundingEmpties(gPos);
	
	if empties.size() == 0:
		return;
	
	for e in empties:
		SpawnRandomBiome(e);
		
func SpawnRandomBiomes_3x3_Influenced(currGPos:Vector2i, prevGPos:Vector2i) -> void:
	
	var spawnPoints:Array[Vector2i] = Get_SurroundingEmpties(currGPos);
	
	if spawnPoints.size() == 0:
		return;
	
	# Get Surrounding Biomes with Grid Positions used to compare with each Spawn Point and get
	# its Adjacent Biome Type, which will determine the Influences used in selecting the
	# Type of the newly Spawned Biome.
	var biomes_WithGPos:Array[Array] = Get_SurroundingBiomeTypes_WithGPos(prevGPos);
	
	var influences:Array[BiomeMaster.Type] = [];
	for b in biomes_WithGPos:
		influences.append(b[1]);
	
	# Add random biome ensure there is always a chance to spawn a different biome region.
	influences.append(BiomeMaster.RandomBiomeType());
	
	for point in spawnPoints:
		for i in biomes_WithGPos:
			if Are_GridPosNeighbours(point, i[0]):
				#var neighbourBias:Array[BiomeMaster.Type] = generalInfluences;
				var neighbourBias:Array[BiomeMaster.Type] = influences;
				# Add One-Off bias for Neighbouring Biome
				neighbourBias.append_array(Get_NeighbourBias(i[1]));
				SpawnBiome(point, neighbourBias.pick_random());
	
func Get_NeighbourBias(neighbourBiome:BiomeMaster.Type) -> Array[BiomeMaster.Type]:
	
	var bias:Array[BiomeMaster.Type] = [];
	
	match neighbourBiome:
		BiomeMaster.Type.Water:
			for c in 4: # We favour Water!
				bias.append(BiomeMaster.Type.Water);
		_:
			for c in 2:
				bias.append(neighbourBiome);
	
	#InGameDebugger.Say(bias);
	
	if bias == []:
		InGameDebugger.Warn("No neighbour biases found.");
	return bias;
	
func Get_SurroundingEmpties(gPos:Vector2i) -> Array[Vector2i]:
	var surrounding_GPos:Array[Vector2i] = Get_GridPosArray3x3(gPos);
	# Remove Empty Positions in case we are at the World Edge
	return Get_EmptyGridPositions(surrounding_GPos);
	
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

func Get_SurroundingBiomeTypes(gPos:Vector2i) -> Array[BiomeMaster.Type]:
	var surrounding_GPos:Array[Vector2i] = Get_GridPosArray3x3(gPos, true);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = Get_OccupiedGridPositions(surrounding_GPos);
	
	var biomesAround:Array[BiomeMaster.Type]; # Array[Grid Pos, Biome Type]
	
	for p in surrounding_GPos:
		biomesAround.append(World.Get_BiomeType(p));
		
	# Debug Message
		
	#var message:String;
		#
	#for i in biomesAround.size():
		#if i == 4:
			#message += "PLAYER";
		#message += str("Biome: ", biomesAround[i], " | ");
		#
	#InGameDebugger.Say(message);
	
	return biomesAround;

func Get_SurroundingBiomeTypes_WithGPos(gPos:Vector2i) -> Array[Array]:
	var surrounding_GPos:Array[Vector2i] = Get_GridPosArray3x3(gPos, true);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = Get_OccupiedGridPositions(surrounding_GPos);
	
	var biomesAround:Array[Array]; # Array[Grid Pos, Biome Type]
	
	for p in surrounding_GPos:
		biomesAround.append([p, World.Get_BiomeType(p)]);
		
	# Debug Message
		
	#var message:String;
		#
	#for i in biomesAround.size():
		#if i == 4:
			#message += "PLAYER";
		#message += str("GridPos: ", biomesAround[i][0], ", Biome: ", biomesAround[i][1], " | ");
		#
	#InGameDebugger.Say(message);
	
	return biomesAround;
	
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
