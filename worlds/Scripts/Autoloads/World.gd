extends Node;

const cellSize:int = 256;

var discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type]

func Record_Biome(gPos:Vector2i, biome:Object, type:BiomeMaster.Type) -> void:
	discoveredBiomes[gPos] = [biome, type];

func Is_Occupied(gPos:Vector2i) -> bool:
	return discoveredBiomes.has(gPos);

func Get_BiomeNode(gPos:Vector2i) -> Object:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos][0];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return null;

func Get_BiomeType(gPos:Vector2i) -> BiomeMaster.Type:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos][1];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return BiomeMaster.Type.NULL;
