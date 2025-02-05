extends Node;

const cellSize:int = 256;

var discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type, Interaction]

var worldSize:int = 1;

func Increase_WorldSize() -> void:
	worldSize += 1;
	
func Get_WorldSize() -> int:
	return worldSize;

func Check_IncreaseWorldSize() -> void:
	#InGameDebugger.Say(discoveredBiomes.size() % 1000);
	#InGameDebugger.Say(worldSize);
	#InGameDebugger.Say("");
	if discoveredBiomes.size() % 1000 == 0:
		Increase_WorldSize();

# Functions: Biomes

func Record_Biome(gPos:Vector2i, biome:Object, type:BiomeMaster.Type, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	discoveredBiomes[gPos] = [biome, type, interType];

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

# Functions: Interactions

func Get_InteractionType(gPos:Vector2i) -> InteractionMaster.Type:
	if !discoveredBiomes.has(gPos):
		InGameDebugger.Warn(str("No Biome or Interaction: ", gPos));
		return InteractionMaster.Type.NULL;
	else:
		return discoveredBiomes[gPos][2];
	
	InGameDebugger.Warn(str("Biome exists, but Interaction NOT found: ", gPos));
	return InteractionMaster.Type.NULL;
