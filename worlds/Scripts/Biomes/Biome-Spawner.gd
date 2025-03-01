extends Node;

@onready var biomePrefab:PackedScene = preload("res://Prefabs/Biome.tscn");

@export var biomeHolder:Node;


func _ready() -> void:
	World.SpawnBiomesAround.connect(On_SpawnBiomesAround);

# [ 1 / 3 ] Functions: Signal Handling ----------------------------------------------------------------------------------------------------

func On_SpawnBiomesAround(gPos:Vector2i, spawnRange:int, influenceRange:int):
	if influenceRange == 0:
		SpawnRandomAround(gPos, spawnRange);
		return;
	SpawnRandomBiomes_Influenced(gPos, spawnRange, influenceRange);

# [ 2 / 3 ] Functions: Biome Spawning ----------------------------------------------------------------------------------------------------

func SpawnRandomBiome(gPos:Vector2i, interType:Interaction_Master.Type = Interaction_Master.Type.NULL) -> void:
	Biome_Master.SpawnBiome(gPos, Biome_Master.RandomBiomeType_Core(), biomeHolder, interType);

func SpawnRandomAround(gPos:Vector2i, spawnRange:int) -> void:
	var surroundingEmpties = GridPos_Utils.Empties_Around(gPos, spawnRange, false);
	for e in surroundingEmpties:
		SpawnRandomBiome(e);

func SpawnRandomBiomes_Influenced(currGPos:Vector2i, spawnRange:int, influenceRange:int) -> void:
	
	var spawnPoints:Array[Vector2i] = GridPos_Utils.Empties_Around(currGPos, spawnRange, false);
	
	if spawnPoints.size() == 0:
		return;
	
	# Get Surrounding Biomes with Grid Positions used to compare with each Spawn Point and get
	# its Adjacent Biome Type, which will determine the Influences used in selecting the
	# Type of the newly Spawned Biome.
	var biomes_WithGPos:Array[Array] = Biome_Master.Surrounding_Biomes_WithGPos(currGPos, influenceRange);
	
	var influences:Array[Biome_Master.Type] = [];
	for b in biomes_WithGPos:
		influences.append(b[1]);
	
	# Add random biome to ensure there is always a chance to spawn a different biome region.
	influences.append(Biome_Master.RandomBiomeType_Core());
	#influences.append_array(World.WorldBiases());
	print(influences);
	
	for point in spawnPoints:
		
		for i in biomes_WithGPos:
			
			if GridPos_Utils.Are_GridPosNeighbours(point, i[0]):
				
				# Add One-Off bias for Neighbouring Biome
				var neighbourBias:Array[Biome_Master.Type] = influences;
				neighbourBias.append_array(NeighbourBias(i[1]));
				
				Biome_Master.SpawnBiome(point, neighbourBias.pick_random(), biomeHolder, Interaction_Master.Type.NULL);
				break;

func On_UpdateBiases(moveDir:Vector2i) -> void:
	pass;

func NeighbourBias(neighbourBiome:Biome_Master.Type) -> Array[Biome_Master.Type]:
	
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
