extends Node;

# Components
var fader:Node;
var sprite:Sprite2D;
# Variables
var currInteraction:InteractionMaster.Type;

func Initialise(biomeType:Biome_Master.Type, interType:InteractionMaster.Type) -> void:
	set_process(false)
	# Initialise Compenents
	fader = $Fader;
	sprite = $"Interaction-Sprite";
	
	if interType == InteractionMaster.Type.NULL:
		
		match randi_range(0, 1):
			0:
				Set_Interaction(InteractionMaster.Type.NULL);
				#Vanish(); # Fade starts as invisible.
				return;
			1:
				Spawn_RandomInteraction(biomeType);

# [ 1 / 4 ] Functions: Spawning ----------------------------------------------------------------------------------------------------

func Spawn_Interaction(interType:InteractionMaster.Type, resetChance:bool = false) -> void:
	Set_Interaction(interType);
	Update_Sprite(interType);
	Appear();
	if resetChance:
		World.Reset_Chance(interType);

func Spawn_RandomInteraction(biomeType:Biome_Master.Type) -> void:
	
	if biomeType == Biome_Master.Type.Water:
		Try_Spawn(biomeType, InteractionMaster.WaterInteractions().pick_random());
		return;
	
	Try_Spawn(biomeType, randi_range(1, InteractionMaster.Type.size() - 1));

func Try_Spawn(biomeType:Biome_Master.Type, interType:InteractionMaster.Type) -> void:
	
	if !Should_Spawn(interType):
		
		#if interType == InteractionMaster.Type.Dog or interType == InteractionMaster.Type.Boat:
			#World.Increase_Chance(interType);
			
		if InteractionMaster.InteractionsWith_IncreasingChance().has(interType):
			World.Increase_Chance(interType);
		
		Set_Interaction(InteractionMaster.Type.NULL);
		Vanish();
		return;
	
	# We still check for Water Biomes here because random combinations 
	# like Water Biome + Dog can still occur.
	
	match interType:
		
		InteractionMaster.Type.Dog:
		
			if biomeType != Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn_Interaction(interType, true);
				InGameDebugger.Say("Spawn: Dog");
				return;
			
		InteractionMaster.Type.Fish:
			
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn_Interaction(interType);
				InGameDebugger.Say("Spawn: Fish");
				return;
				
		InteractionMaster.Type.Boat:
			
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn_Interaction(interType, true);
				InGameDebugger.Say("Spawn: Boat");
				return;
			
	Set_Interaction(InteractionMaster.Type.NULL);
	Vanish();
	return;

func Should_Spawn(interType:InteractionMaster.Type) -> bool:
	return randi_range(0, World.Get_Chance(interType)) == 0;

# [ 2 / 4 ] Functions: Get Set Interaction ----------------------------------------------------------------------------------------------------

func Set_Interaction(type:InteractionMaster.Type) -> void:
	currInteraction = type;

func Get_Interaction() -> InteractionMaster.Type:
	return currInteraction;

# [ 3 / 4 ] Functions: Sprite ----------------------------------------------------------------------------------------------------

func Vanish() -> void:
	fader.FadeToTrans();

func Appear() -> void:
	fader.FadeToOpaque(1);
	
func Update_Sprite(interType:InteractionMaster.Type) -> void:
	match interType:
		InteractionMaster.Type.Dog:
			sprite.region_rect.position = Vector2i(0, 1024);
		InteractionMaster.Type.Fish:
			sprite.region_rect.position = Vector2i(0, 1792);
		InteractionMaster.Type.Boat:
			sprite.region_rect.position = Vector2i(256, 1536);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

# [ 4 / 4 ] Functions: Grid Position ----------------------------------------------------------------------------------------------------

func Get_GridPosition() -> Vector2i:
	return get_parent().Get_GridPosition();
