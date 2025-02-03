extends Node;

const cellSize:int = 256;

var discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type, Interaction]

func Record_Biome(gPos:Vector2i, biome:Object, type:BiomeMaster.Type, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	discoveredBiomes[gPos] = [biome, type];
	if interType != InteractionMaster.Type.NULL:
		discoveredBiomes[gPos].push_back(interType);

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

# Interactions

func Get_InteractionType(gPos:Vector2i) -> InteractionMaster.Type:
	if !discoveredBiomes.has(gPos):
		InGameDebugger.Warn(str("No Biome or Interaction: ", gPos));
		return InteractionMaster.Type.NULL;
	else:
		if discoveredBiomes[gPos].size() > 2:
			return discoveredBiomes[gPos][2];
	
	InGameDebugger.Warn(str("Biome exists, but Interaction NOT found: ", gPos));
	return InteractionMaster.Type.NULL;
