extends Node2D;

# Components
var fader:Node;
var sprite:Sprite2D;
var updater:Node;
# Variables
var currInteraction:InteractionMaster.Type = InteractionMaster.Type.NULL;

func Initialise(biomeType:Biome_Master.Type, interType:InteractionMaster.Type) -> void:

	# Initialise Compenents
	fader = $Fader;
	sprite = $"Interaction-Sprite";
	updater = $Updater;
	
	if interType != InteractionMaster.Type.NULL:
		Spawn(interType);
		return;
		
	Spawn_RandomInteraction(biomeType);

# [ 1 / 4 ] Functions: Spawning ----------------------------------------------------------------------------------------------------

func Spawn_RandomInteraction(biomeType:Biome_Master.Type) -> void:
	
	# Spawn interactions specific to the water biome
	if biomeType == Biome_Master.Type.Water:
		Try_Spawn(biomeType, InteractionMaster.WaterInteractions().pick_random());
		return;
	
	#Try_Spawn(biomeType, randi_range(1, InteractionMaster.Type.size() - 1));
	Try_Spawn(biomeType, InteractionMaster.LandInteractions().pick_random());

func Try_Spawn(biomeType:Biome_Master.Type, interType:InteractionMaster.Type) -> void:
	
	if !Should_Spawn(interType):
			
		if InteractionMaster.InteractionsWith_IncreasingChance().has(interType):
			World.Increase_Chance(interType);
		
		Disable_Interaction(0);
		return;
	
	# We still check for Water Biomes here because random combinations 
	# like Water Biome + Dog can still occur.

	match interType:
			
		InteractionMaster.Type.Dog:
			if biomeType != Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn(interType, true);
				AudioMaster.PlaySFX_DogBark(global_position);
				return;
				
		InteractionMaster.Type.Forest:
			if biomeType == Biome_Master.Type.Grass:
				Spawn(interType);
				return;
			
		InteractionMaster.Type.Fish:
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn(interType);
				return;
				
		InteractionMaster.Type.Boat:
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn(interType, true);
				return;
			
	Disable_Interaction(0);
	return;

func Should_Spawn(interType:InteractionMaster.Type) -> bool:
	return World.Pass_ProbabilityCheck(World.Get_Chance(interType));

func Spawn(interType:InteractionMaster.Type, resetChance:bool = false) -> void:
	Enable_Interaction(interType);
	#InGameDebugger.Say(str("Spawned: ", InteractionMaster.Type.keys()[interType]));
	#InGameDebugger.Say(str(InteractionMaster.Type.keys()[interType], " Chance: ", World.Get_Chance(interType)));
	if resetChance:
		World.Reset_Chance(interType);

# [ 2 / 4 ] Functions: Get Set Interaction ----------------------------------------------------------------------------------------------------

func Enable_Interaction(interType:InteractionMaster.Type) -> void:
	Set_Interaction(interType);
	Update_Sprite(interType);
	Appear();
	# Hook up the Interaction Updater in the next frame to
	# prevent it from updating as soon as it's connected.
	await get_tree().process_frame;
	updater.Connect_TimeTick();
	
func Disable_Interaction(vanishSpd:float = 2) -> void:
	Set_Interaction(InteractionMaster.Type.NULL);
	if vanishSpd == 0:
		return;
	Vanish(vanishSpd);

func Set_Interaction(type:InteractionMaster.Type) -> void:
	currInteraction = type;

func Get_Interaction() -> InteractionMaster.Type:
	return currInteraction;

# [ 3 / 4 ] Functions: Sprite ----------------------------------------------------------------------------------------------------

func Vanish(speed:float = 2) -> void:
	fader.FadeToTrans(speed);

func Appear(speed:float = 2) -> void:
	fader.FadeToOpaque(speed);
	
func Update_Sprite(interType:InteractionMaster.Type) -> void:
	match interType:
		InteractionMaster.Type.Dog:
			sprite.region_rect.position = Vector2i(0, 2048);
		InteractionMaster.Type.Forest:
			sprite.region_rect.position = Vector2i(1792, 1536);
		InteractionMaster.Type.Fish:
			sprite.region_rect.position = Vector2i(0, 1792);
		InteractionMaster.Type.Boat:
			sprite.region_rect.position = Vector2i(256, 1536);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

# [ 4 / 4 ] Functions: Grid Position ----------------------------------------------------------------------------------------------------

func Get_GridPosition() -> Vector2i:
	return get_parent().Get_GridPosition();
