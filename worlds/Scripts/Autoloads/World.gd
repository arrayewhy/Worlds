extends Node;

const cellSize:int = 256;

var discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type, Interaction]

var worldSize:int = 1;

const maxChance:int = 999;
var chances:Dictionary; # Biome_Master.Type : int
const initChance_Dog:int = 0;
const initChance_Fish:int = 990;
const initChance_Boat:int = 0;

func _ready() -> void:
	Initialise_Chances();

# Functions: World Size

func Increase_WorldSize() -> void:
	worldSize += 1;
	
func Get_WorldSize() -> int:
	return worldSize;

func IncreaseWorldSize() -> void:
	if discoveredBiomes.size() % 1000 == 0:
		Increase_WorldSize();

# Functions: Biomes

func Record_Biome(gPos:Vector2i, biome:Object, type:Biome_Master.Type) -> void:
	discoveredBiomes[gPos] = [biome, type];

func Is_Occupied(gPos:Vector2i) -> bool:
	return discoveredBiomes.has(gPos);

func Get_BiomeNode(gPos:Vector2i) -> Object:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos][0];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return null;

func Get_BiomeType(gPos:Vector2i) -> Biome_Master.Type:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos][1];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return Biome_Master.Type.NULL;

# Functions: Interactions

func Record_Interaction(gPos:Vector2i, interType:InteractionMaster.Type) -> void:
	# We record a biome's Interaction in the 3rd element of its array so it contains:
	# [Biome Object, Biome Type, Interaction]
	if discoveredBiomes[gPos].size() > 2:
		discoveredBiomes[gPos][2] = interType;
		return;
	discoveredBiomes[gPos].push_back(interType);

func Get_InteractionType(gPos:Vector2i) -> InteractionMaster.Type:
	if !discoveredBiomes.has(gPos):
		InGameDebugger.Warn(str("No Biome, so no Interaction: ", gPos));
		return InteractionMaster.Type.NULL;
	else:
		return discoveredBiomes[gPos][2];

func Get_Chance(type:InteractionMaster.Type) -> int:
	# We pick from a random range [0, chance], so if the chance starts at ZERO, 
	# and we pick from [0, 0], it is a 100% instead of what we intend which is 0% Chance.
	# So to make it work as intended, we minus the Chance from 999, and return that.
	# This way, we are picking 1 from [0, 999] at a very low Chance.
	return Get_MaxChance() - chances[type];
	
func Increase_Chance(type:InteractionMaster.Type, rate:int = 1) -> void:
	if chances[type] < Get_MaxChance():
		chances[type] += rate;

func Reset_Chance(type:InteractionMaster.Type) -> void:
	match type:
		InteractionMaster.Type.Dog:
			chances[type] = initChance_Dog;
		InteractionMaster.Type.Fish:
			chances[type] = initChance_Fish;
		InteractionMaster.Type.Boat:
			chances[type] = initChance_Boat;

func Initialise_Chances() -> void:
	
	for i in InteractionMaster.Type.size():
		chances[i] = 0;

	for c in chances.keys():
		Reset_Chance(c);

func Get_MaxChance() -> int:
	return maxChance;

func Win_ImprobableRoll() -> bool:
	return randi_range(0, Get_MaxChance()) == 0;
