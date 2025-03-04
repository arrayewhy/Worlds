extends Node;

# Constants
const _cellSize:int = 256;
# Variables: World
var worldSize:int = 1;
var _playerGridPos:Vector2i;
# Variables: Biomes
var _discoveredBiomes = {}; # Grid Position : [Biome Object, Biome Type]
#var _currBiases:Dictionary;
const _maxInfluence:int = 10;
# Variables: Interaction
var _interChances:Dictionary; # Interaction_Master.Type : int
# Signals
signal SpawnBiomesAround(gPos, range, influenceRange);
signal TimeTick;

signal RollDice;

func _ready() -> void:
	Interaction_Master.Initialise_Chances(_interChances);
	#_currBiases = Init_Biases();

func Roll_Dice() -> void:
	RollDice.emit();

# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func SpawnBiomesAround_Player(currGPos:Vector2i, spawnRange:int = 2, influenceRange:int = 1) -> void:
	_playerGridPos = currGPos;
	SpawnBiomes_Around(currGPos, spawnRange, influenceRange);

func SpawnBiomes_Around(gPos:Vector2i, spawnRange:int = 1, influenceRange:int = 0) -> void:
	SpawnBiomesAround.emit(gPos, spawnRange, influenceRange);
	
func Advance_Time() -> void:
	TimeTick.emit();

# Functions: World Size ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func CellSize() -> int:
	return _cellSize;

func Increase_WorldSize() -> void:
	worldSize += 1;
	
func Get_WorldSize() -> int:
	return worldSize;

func IncreaseWorldSize() -> void:
	if _discoveredBiomes.size() % 1000 == 0:
		Increase_WorldSize();

# Functions: Interactions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func InteractionChances() -> Dictionary:
	return _interChances;

# Functions: Biomes ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func DiscoveredBiomes() -> Dictionary:
	return _discoveredBiomes;

# Functions: Biome Bias ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

#func UpdateBiases_AccordingTo_DistFromCenter(moveDir:Vector2i) -> void:
	#match moveDir.y:
		#-1:
			#if _playerGridPos.y <= -10:
				#
				#if _currBiases["Grass"] > 0:
					#_currBiases["Grass"] -= 2;
					#
				#_currBiases["Stone"] += 2;
				#
			#if _currBiases["Water"] > 0:
					#_currBiases["Water"] -= 4;
					#
		#1:
			#if _playerGridPos.y > -10:
				#
				#if _currBiases["Grass"] < _maxInfluence:
					#_currBiases["Grass"] += 2;
					#
				#_currBiases["Water"] += 4;
			#
			#if _currBiases["Stone"] > 0:
				#_currBiases["Stone"] -= 2;
			#
#
#func WorldBiases() -> Array[Biome_Master.Type]:
	#
	#var biases:Array[Biome_Master.Type];
	#
	#for c in _currBiases:
		#for i in _currBiases.get(c):
			#biases.append(Biome_Master.Type[c]);
#
	#return biases;
#
#func Init_Biases() -> Dictionary:
	#
	#var biases:Dictionary = {};
	#
	#for type in Biome_Master.Type.keys():
		#if type == "NULL":
			#continue;
		#biases[type] = 0;
		#
	#return biases;

# Functions: Player ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func PlayerGridPos() -> Vector2i:
	return _playerGridPos;

func Set_PlayerGridPos(gPos:Vector2i) -> void:
	_playerGridPos = gPos;
