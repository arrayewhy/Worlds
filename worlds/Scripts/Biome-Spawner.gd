extends Node;

@export var biomeHolder:Node;

func _ready() -> void:
	get_parent().SpawnAround.connect(SpawnRandomBiomes_3x3);

# Single Biome

func SpawnBiome(gPos:Vector2i, type:Biome.Type) -> void:
	
	var newBiome = Instantiate_BiomeNode(type);
	
	biomeHolder.add_child(newBiome);
	# Position New Biome in World Space
	var newPos:Vector2 = Vector2(gPos) * World.cellSize;
	# Randomise position slightly
	newPos += Vector2(randf_range(-8, 8), randf_range(-8, 8));
	newBiome.position = newPos;
	
	World.Record_Biomes({gPos:newBiome});
	
	InGameDebugger.Say(str(gPos, " : ", World.Get_BiomeType(gPos)), true);
	
func Instantiate_BiomeNode(type:Biome.Type) -> Node2D:
	return Biome.Get_BiomePrefab(type).instantiate();

# Multiple Biomes
	
func SpawnRandomBiomes_3x3(gPos:Vector2i) -> void:
	
	var surrounding = Get_GridPosArray3x3(gPos);
	surrounding = Remove_Occupied(surrounding);
	
	for e in surrounding:
		SpawnBiome(e, Biome.Type.Earth);
	
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
