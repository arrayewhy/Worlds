extends Node;

const cellSize:int = 256;

var discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type, Interaction]

var worldSize:int = 1;

const maxChance:int = 999;
var chance_dog:int = 0;

func Increase_WorldSize() -> void:
	worldSize += 1;
	
func Get_WorldSize() -> int:
	return worldSize;

func Check_IncreaseWorldSize() -> void:
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
		InGameDebugger.Warn(str("No Biome, so no Interaction: ", gPos));
		return InteractionMaster.Type.NULL;
	else:
		return discoveredBiomes[gPos][2];

# Interactions

func Get_MaxChance() -> int:
	return maxChance;

func GetChance_Dog() -> int:
	# We pick from a random range [0, chance], so if the chance starts at ZERO, 
	# and we pick from [0, 0], it is a 100% instead of what we intend which is 0% Chance.
	# So to make it work as intended, we minus the Chance from 999, and return that.
	# This way, we are picking 1 from [0, 999] at a very low Chance.
	return maxChance - chance_dog;
	
func IncreaseChance_Dog() -> void:
	if chance_dog < maxChance:
		chance_dog += 1;

func ResetChance_Dog() -> void:
	chance_dog = 0;
