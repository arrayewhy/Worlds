extends Node;

@onready var biomePrefab:PackedScene = preload("res://Prefabs/Biomes/Biome.tscn");

@export var biomeHolder:Node;

func _ready() -> void:
	get_parent().SpawnInit.connect(SpawnInitBiomes);
	get_parent().SpawnAround.connect(On_SpawnAround);

# [ 1 / 3 ] Functions: Biome Spawning ----------------------------------------------------------------------------------------------------

func SpawnBiome(gPos:Vector2i, type:Biome_Master.Type, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	var newBiome:Object = biomePrefab.instantiate();
	newBiome.Initialise(gPos, type);
	biomeHolder.add_child(newBiome);
	# Position New Biome in World Space with slight randomisation
	var newPos:Vector2 = Vector2(gPos) * World.cellSize;
	newPos += Vector2(randf_range(-6, 6), randf_range(-6, 6));
	newBiome.position = newPos;
	# Record the biome
	World.Record_Biome(gPos, newBiome, type);
	newBiome.Initialise_Interaction(gPos, type, interType);
	World.IncreaseWorldSize();
	# Debug Message
	#InGameDebugger.Say(str(gPos, " : ", World.Get_BiomeType(gPos), ", ", World.Get_InteractionType(gPos)), true);
	
func SpawnRandomBiome(gPos:Vector2i, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	SpawnBiome(gPos, Biome_Master.RandomBiomeType(), interType);
		
func SpawnRandomBiomes(gPos:Vector2i, reach:int) -> void:
	var empties:Array[Vector2i] = GridPos_Utils.Get_Surrounding_Empties(gPos, reach);
	if empties.size() > 0:
		for e in empties:
			SpawnRandomBiome(e);

func SpawnRandomBiomes_Influenced(currGPos:Vector2i, _prevGPos:Vector2i, spawnRange:int, influenceRange:int) -> void:
	
	var spawnPoints:Array[Vector2i] = GridPos_Utils.Get_Surrounding_Empties(currGPos, spawnRange);
	
	if spawnPoints.size() == 0:
		return;
	
	# Remove a random spawn point just for fun!
	if spawnPoints.size() > 1:
		spawnPoints.remove_at(randi_range(0, spawnPoints.size() - 1));
	
	# Get Surrounding Biomes with Grid Positions used to compare with each Spawn Point and get
	# its Adjacent Biome Type, which will determine the Influences used in selecting the
	# Type of the newly Spawned Biome.
	var biomes_WithGPos:Array[Array] = Get_Surrounding_BiomeTypes_WithGPos(currGPos, influenceRange);
	
	var influences:Array[Biome_Master.Type] = [];
	for b in biomes_WithGPos:
		influences.append(b[1]);
	
	# Add random biome to ensure there is always a chance to spawn a different biome region.
	influences.append(Biome_Master.RandomBiomeType());
	
	for point in spawnPoints:
		for i in biomes_WithGPos:
			if GridPos_Utils.Are_GridPosNeighbours(point, i[0]):
				var neighbourBias:Array[Biome_Master.Type] = influences;
				# Add One-Off bias for Neighbouring Biome
				neighbourBias.append_array(Get_NeighbourBias(i[1]));
				SpawnBiome(point, neighbourBias.pick_random());
				#InGameDebugger.Say("Spawn!")
				break;
	#InGameDebugger.Say("\n");

func On_SpawnAround(currGPos:Vector2i, prevGPos:Vector2i) -> void:
	SpawnRandomBiomes_Influenced(currGPos, prevGPos, 2, 1);

func SpawnInitBiomes(gPos:Vector2i) -> void:
	var surroundingEmpties = GridPos_Utils.GridPositions_Around(gPos, 1);
	for e in surroundingEmpties:
		SpawnRandomBiome(e);
	get_parent().SpawnInit.disconnect(SpawnInitBiomes);

# [ 2 / 3 ] Functions: Bias ----------------------------------------------------------------------------------------------------

func Get_NeighbourBias(neighbourBiome:Biome_Master.Type) -> Array[Biome_Master.Type]:
	
	var bias:Array[Biome_Master.Type] = [];
	
	match neighbourBiome:
		Biome_Master.Type.Water:
			for c in 4: # We favour Water!
				bias.append(Biome_Master.Type.Water);
		_:
			for c in 2:
				bias.append(neighbourBiome);
	
	#InGameDebugger.Say(bias);
	
	if bias == []:
		InGameDebugger.Warn("No neighbour biases found.");
	return bias;

# [ 3 / 3 ] Functions: Biome Types ----------------------------------------------------------------------------------------------------

func Get_Surrounding_BiomeTypes(gPos:Vector2i, reach:int) -> Array[Biome_Master.Type]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Get_Occupied(surrounding_GPos);
	
	var biomesAround:Array[Biome_Master.Type]; # Array[Grid Pos, Biome Type]
	
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

func Get_Surrounding_BiomeTypes_WithGPos(gPos:Vector2i, reach:int) -> Array[Array]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Get_Occupied(surrounding_GPos);
	
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
