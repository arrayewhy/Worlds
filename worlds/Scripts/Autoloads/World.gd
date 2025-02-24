extends Node;

# Constants
const cellSize:int = 256;
# Variables: World
var discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type]
var worldSize:int = 1;
var playerGridPos:Vector2i;
# Variables: Interaction
const maxChance:int = 10000;
const improbChance:int = 100000;
var chances:Dictionary; # InteractionMaster.Type : int
const initChance_Dog:int = 0;
const initChance_Forest:int = 10000;
const initChance_Fish:int = 1000;
const initChance_Boat:int = 0;

# Signals
signal SpawnBiomesAroundPlayer(currGPos, prevGPos);
signal SpawnBiomes(gPos);
signal TimeTick;

signal RollDice;

func _ready() -> void:
	Initialise_Chances();

func Roll_Dice() -> void:
	RollDice.emit();

# Functions: Signals ----------------------------------------------------------------------------------------------------

func SpawnBiomes_AroundPlayer(currGPos:Vector2i, prevGPos:Vector2i) -> void:
	playerGridPos = currGPos;
	SpawnBiomesAroundPlayer.emit(currGPos, prevGPos);

func SpawnBiomes_Around(gPos:Vector2i) -> void:
	SpawnBiomes.emit(gPos);
	
func Advance_Time() -> void:
	TimeTick.emit();

# Functions: World Size ----------------------------------------------------------------------------------------------------

func Increase_WorldSize() -> void:
	worldSize += 1;
	
func Get_WorldSize() -> int:
	return worldSize;

func IncreaseWorldSize() -> void:
	if discoveredBiomes.size() % 1000 == 0:
		Increase_WorldSize();

# Functions: Biomes ----------------------------------------------------------------------------------------------------

func Record_Biome(gPos:Vector2i, biome:Object, type:Biome_Master.Type) -> void:
	discoveredBiomes[gPos] = [biome, type];

func Is_Occupied(gPos:Vector2i) -> bool:
	return discoveredBiomes.has(gPos);

func Get_BiomeObject(gPos:Vector2i) -> Object:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos][0];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return null;

func Get_BiomeType(gPos:Vector2i) -> Biome_Master.Type:
	
	if discoveredBiomes.has(gPos):
		return discoveredBiomes[gPos][1];
	
	InGameDebugger.Warn(str("Biome NOT found: ", gPos));
	return Biome_Master.Type.NULL;

func Surrounding_Biomes(gPos:Vector2i, reach:int) -> Array[Biome_Master.Type]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Remove_Empty(surrounding_GPos);
	
	var biomesAround:Array[Biome_Master.Type]; # Array[Biome Type]
	
	for p in surrounding_GPos:
		biomesAround.append(World.Get_BiomeType(p));
	
	return biomesAround;

func Surrounding_Biomes_WithGPos(gPos:Vector2i, reach:int) -> Array[Array]:
	var surrounding_GPos:Array[Vector2i] = GridPos_Utils.GridPositions_Around(gPos, reach);
	# Remove Empty Positions in case we are at the World Edge
	surrounding_GPos = GridPos_Utils.Remove_Empty(surrounding_GPos);
	
	var biomesAround:Array[Array]; # Array[Grid Pos, Biome Type]
	
	for p in surrounding_GPos:
		biomesAround.append([p, World.Get_BiomeType(p)]);
	
	return biomesAround;

# Functions: Interactions ----------------------------------------------------------------------------------------------------

func Get_InteractionType(gPos:Vector2i) -> InteractionMaster.Type:
	if !discoveredBiomes.has(gPos):
		InGameDebugger.Warn(str("No Biome, so no Interaction: ", gPos));
		return InteractionMaster.Type.NULL;
	else:
		return discoveredBiomes[gPos][0].Get_Interaction();

func Get_Chance(type:InteractionMaster.Type) -> int:
	return chances[type];
	
func Increase_Chance(type:InteractionMaster.Type, rate:int = 1) -> void:
	if chances[type] < Get_MaxChance():
		chances[type] += rate;

func Reset_Chance(type:InteractionMaster.Type) -> void:
	match type:
		InteractionMaster.Type.Dog:
			chances[type] = initChance_Dog;
		InteractionMaster.Type.Forest:
			chances[type] = initChance_Forest;
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
	return randi_range(0, improbChance) == 0;

func Pass_ProbabilityCheck(chance:int) -> bool:
	var result = randi_range(0, maxChance - 1);
	return result > maxChance - chance;

# Functions: Player ----------------------------------------------------------------------------------------------------

func PlayerGridPos() -> Vector2i:
	return playerGridPos;
