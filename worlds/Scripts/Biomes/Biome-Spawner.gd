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
		
	#InGameDebugger.Say(""); # Add space between the last debug message and the next one.
		
func SpawnRandomBiomes_3x3_Influenced(currGPos:Vector2i, prevGPos:Vector2i) -> void:
	
	var empties:Array[Vector2i] = Get_SurroundingEmpties(currGPos);
	
	if empties.size() == 0:
		return;
	
	var biomesAround:Array[Array] = Get_BiomeTypesAround_WithGPos(prevGPos);
	
	var unsortedInfluences:Array[BiomeMaster.Type] = [];
	
	for b in biomesAround:
		unsortedInfluences.append(b[1]);
	
	for e in empties:
		
		var influences:Array[BiomeMaster.Type] = [];
		influences.append_array(unsortedInfluences);
		# Add random biome ensure there is always a chance to spawn a different biome region.
		influences.append(BiomeMaster.RandomBiomeType());
		
		for i in biomesAround:
			if Are_GridPosNeighbours(e, i[0]):
				
				# Add bias for Neighbouring Biome
				for c in 2:
					influences.append(i[1]);
				
				#InGameDebugger.Say(influences);
				
				SpawnBiome(e, influences.pick_random());
	
	#InGameDebugger.Say(""); # Add space between the last debug message and the next one.
	
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

func Get_BiomeTypesAround(gPos:Vector2i) -> Array[BiomeMaster.Type]:
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

func Get_BiomeTypesAround_WithGPos(gPos:Vector2i) -> Array[Array]:
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
