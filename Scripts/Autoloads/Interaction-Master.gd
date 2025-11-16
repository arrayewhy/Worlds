class_name Interaction_Master extends Node;

enum Type {NULL, Grass, Dog, Forest, Fish, Boat};

const maxChance:int = 10000;
const improbChance:int = 100000;

const initChance_Grass:int = 5000
const initChance_Dog:int = -500;
const initChance_Forest:int = 5000;
const initChance_Fish:int = 500;
const initChance_Boat:int = -1000;

# Functions ----------------------------------------------------------------------------------------------------

static func LandInteractions() -> Array[Type]:
	return [Type.Grass, Type.Forest, Type.Dog];

static func WaterInteractions() -> Array[Type]:
	return [Type.Fish, Type.Boat];

static func InteractionsWith_IncreasingChance() -> Array[Type]:
	return [Type.Dog, Type.Boat, Type.Fish];

# Functions ----------------------------------------------------------------------------------------------------

static func Get_InteractionType(gPos:Vector2i, discBiomes:Dictionary = World.DiscoveredBiomes()) -> Interaction_Master.Type:
	if !discBiomes.has(gPos):
		InGameDebugger.Warn(str("No Biome, so no Interaction: ", gPos));
		return Interaction_Master.Type.NULL;
	else:
		return discBiomes[gPos][0].Get_Interaction();

static func Get_Chance(type:Interaction_Master.Type, interChances:Dictionary = World.InteractionChances()) -> int:
	return interChances[type];
	
static func Increase_Chance(type:Interaction_Master.Type, rate:int = 1, interChances:Dictionary = World.InteractionChances()) -> void:
	if interChances[type] < Get_MaxChance():
		interChances[type] += rate;

static func Reset_Chance(type:Interaction_Master.Type, interChances:Dictionary = World.InteractionChances()) -> void:
	match type:
		Interaction_Master.Type.Grass:
			interChances[type] = initChance_Grass;
		Interaction_Master.Type.Dog:
			interChances[type] = initChance_Dog;
		Interaction_Master.Type.Forest:
			interChances[type] = initChance_Forest;
		Interaction_Master.Type.Fish:
			interChances[type] = initChance_Fish;
		Interaction_Master.Type.Boat:
			interChances[type] = initChance_Boat;

static func Initialise_Chances(interChances:Dictionary) -> void:
	
	for i in Interaction_Master.Type.size():
		interChances[i] = 0;

	for c in interChances.keys():
		Reset_Chance(c);

static func Get_MaxChance() -> int:
	return maxChance;

static func Win_ImprobableRoll() -> bool:
	return randi_range(0, improbChance) == 0;

static func Pass_ProbabilityCheck(chance:int) -> bool:
	
	var result:int;
	
	# If chance is a Negative value, randomly pick between 0 and maxChance plus the the absolute of chance, 
	# and see if the number is 0;
	# Example: Aim for 0 in [0, 10000 + abs(-500)]
	
	if chance < 0:
		result = randi_range(0, maxChance + abs(chance));
		return result == 0;
	
	# If chance is a positive value, randomly pick between 0 and maxChance, 
	# and see if the number is between 0 and chance.
	
	result = randi_range(0, maxChance);
	return result < chance;
