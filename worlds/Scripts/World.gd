extends Node;

const cellSize:int = 256;

var discoveredBiomes = {};

func Record_Biomes(biomes:Dictionary) -> void:
	for key in biomes.keys():
		discoveredBiomes[key] = biomes.get(key);

func Is_Occupied(gPos:Vector2i) -> bool:
	return discoveredBiomes.has(gPos);

func Get_BiomeNode(gPos:Vector2i) -> Node:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return null;

func Get_BiomeType(gPos:Vector2i) -> Biome.Type:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos].type;
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return Biome.Type.NULL;
