extends Node2D;

# Components
var fader:Node;
var sprite:Sprite2D;
var updater:Node;
# Variables
var currInteraction:Interaction_Master.Type = Interaction_Master.Type.NULL;

func Initialise(biomeType:Biome_Master.Type, interType:Interaction_Master.Type) -> void:

	# Initialise Compenents
	fader = $Fader;
	sprite = $"Interaction-Sprite";
	updater = $Updater;
	
	if interType != Interaction_Master.Type.NULL:
		Spawn(interType);
		return;
		
	Spawn_RandomInteraction(biomeType);

# [ 1 / 4 ] Functions: Spawning ----------------------------------------------------------------------------------------------------

func Spawn_RandomInteraction(biomeType:Biome_Master.Type) -> void:
	
	# Spawn interactions specific to the water biome
	if biomeType == Biome_Master.Type.Water:
		Try_Spawn(biomeType, Interaction_Master.WaterInteractions().pick_random());
		return;
	
	#Try_Spawn(biomeType, randi_range(1, Interaction_Master.Type.size() - 1));
	Try_Spawn(biomeType, Interaction_Master.LandInteractions().pick_random());

func Try_Spawn(biomeType:Biome_Master.Type, interType:Interaction_Master.Type) -> void:
	
	if !Should_Spawn(interType):
			
		if Interaction_Master.InteractionsWith_IncreasingChance().has(interType):
			Interaction_Master.Increase_Chance(interType);
		
		Disable_Interaction(0);
		return;
	
	# We still check for Water Biomes here because random combinations 
	# like Water Biome + Dog can still occur.

	match interType:
			
		Interaction_Master.Type.Dog:
			if biomeType != Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn(interType, true);
				AudioMaster.PlaySFX_DogBark(global_position);
				return;
				
		Interaction_Master.Type.Forest:
			if biomeType == Biome_Master.Type.Grass:
				Spawn(interType);
				return;
			
		Interaction_Master.Type.Fish:
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn(interType);
				return;
				
		Interaction_Master.Type.Boat:
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn(interType, true);
				return;
			
	Disable_Interaction(0);
	return;

func Should_Spawn(interType:Interaction_Master.Type) -> bool:
	return Interaction_Master.Pass_ProbabilityCheck(Interaction_Master.Get_Chance(interType));

func Spawn(interType:Interaction_Master.Type, resetChance:bool = false) -> void:
	Enable_Interaction(interType);
	#InGameDebugger.Say(str("Spawned: ", Interaction_Master.Type.keys()[interType]));
	#InGameDebugger.Say(str(Interaction_Master.Type.keys()[interType], " Chance: ", World.Get_Chance(interType)));
	if resetChance:
		Interaction_Master.Reset_Chance(interType);

# [ 2 / 4 ] Functions: Get Set Interaction ----------------------------------------------------------------------------------------------------

func Enable_Interaction(interType:Interaction_Master.Type) -> void:
	Set_Interaction(interType);
	Update_Sprite(interType);
	Appear();
	# Hook up the Interaction Updater in the next frame to
	# prevent it from updating as soon as it's connected.
	await get_tree().process_frame;
	updater.Connect_TimeTick();
	
func Disable_Interaction(vanishSpd:float = 2) -> void:
	Set_Interaction(Interaction_Master.Type.NULL);
	if vanishSpd == 0:
		return;
	Vanish(vanishSpd);

func Set_Interaction(type:Interaction_Master.Type) -> void:
	currInteraction = type;

func Get_Interaction() -> Interaction_Master.Type:
	return currInteraction;

# [ 3 / 4 ] Functions: Sprite ----------------------------------------------------------------------------------------------------

func Vanish(speed:float = 2) -> void:
	fader.FadeToTrans(speed);

func Appear(speed:float = 2) -> void:
	fader.FadeToOpaque(speed);
	
func Update_Sprite(interType:Interaction_Master.Type) -> void:
	match interType:
		Interaction_Master.Type.Dog:
			sprite.region_rect.position = Vector2i(0, 2048);
		Interaction_Master.Type.Forest:
			sprite.region_rect.position = Vector2i(1792, 1536);
		Interaction_Master.Type.Fish:
			sprite.region_rect.position = Vector2i(0, 1792);
		Interaction_Master.Type.Boat:
			sprite.region_rect.position = Vector2i(256, 1536);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

# [ 4 / 4 ] Functions: Grid Position ----------------------------------------------------------------------------------------------------

func Get_GridPosition() -> Vector2i:
	return get_parent().Get_GridPosition();
