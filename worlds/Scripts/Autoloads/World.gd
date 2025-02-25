extends Node;

# Constants
const _cellSize:int = 256;
# Variables: World
var worldSize:int = 1;
var _playerGridPos:Vector2i;
# Variables: Biomes
var _discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type]
# Variables: Interaction
var _interChances:Dictionary; # Interaction_Master.Type : int


# Signals
#signal SpawnBiomesAroundPlayer(currGPos, prevGPos);
signal SpawnBiomesAround(gPos, range, influenceRange);
signal TimeTick;

signal RollDice;

func _ready() -> void:
	Interaction_Master.Initialise_Chances(_interChances);

func Roll_Dice() -> void:
	RollDice.emit();

# Functions: Signals ----------------------------------------------------------------------------------------------------

func SpawnBiomesAround_Player(currGPos:Vector2i, spawnRange:int = 2, influenceRange:int = 1) -> void:
	_playerGridPos = currGPos;
	#SpawnBiomesAround.emit(currGPos, 3, true);
	SpawnBiomes_Around(currGPos, spawnRange, influenceRange);

func SpawnBiomes_Around(gPos:Vector2i, spawnRange:int = 1, influenceRange:int = 0) -> void:
	SpawnBiomesAround.emit(gPos, spawnRange, influenceRange);
	
func Advance_Time() -> void:
	TimeTick.emit();

# Functions: World Size ----------------------------------------------------------------------------------------------------

func CellSize() -> int:
	return _cellSize;

func Increase_WorldSize() -> void:
	worldSize += 1;
	
func Get_WorldSize() -> int:
	return worldSize;

func IncreaseWorldSize() -> void:
	if _discoveredBiomes.size() % 1000 == 0:
		Increase_WorldSize();

# Functions: Interactions ----------------------------------------------------------------------------------------------------

func InteractionChances() -> Dictionary:
	return _interChances;

# Functions: Biomes ----------------------------------------------------------------------------------------------------

func DiscoveredBiomes() -> Dictionary:
	return _discoveredBiomes;

# Functions: Player ----------------------------------------------------------------------------------------------------

func PlayerGridPos() -> Vector2i:
	return _playerGridPos;
