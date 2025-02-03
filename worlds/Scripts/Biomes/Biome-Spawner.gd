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
	SpawnBiome(gPos, 3, interType);
	
func Instantiate_BiomeNode(type:BiomeMaster.Type) -> Node2D:
	var newBiome:Object = biomePrefab.instantiate();
	newBiome.Initialise(type);
	return newBiome;

# Multiple Biomes
	
func SpawnRandomBiomes_3x3(gPos:Vector2i) -> void:
	var surroundingPos = Get_GridPosArray3x3(gPos);
	surroundingPos = Remove_Occupied(surroundingPos);
	for e in surroundingPos:
		SpawnRandomBiome(e);
		#SpawnBiome(e, BiomeMaster.Type.Earth);
	
func Get_GridPosArray3x3(gPos:Vector2i) -> Array:
	return [
		gPos + Vector2i(-1,-1), gPos + Vector2i.UP, gPos + Vector2i(1,-1),
		gPos + Vector2i.LEFT, gPos + Vector2i.RIGHT,
		gPos + Vector2i(-1,1), gPos + Vector2i.DOWN, gPos + Vector2i(1,1),
		];

func Remove_Occupied(gPosArray:Array) -> Array:
	var empties = [];
	for gPos in gPosArray:
		if !World.Is_Occupied(gPos):
			empties.append(gPos);
	return empties;
