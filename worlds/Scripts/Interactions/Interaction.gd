extends Node;

# Components
var fader:Node;
var sprite:Sprite2D;
# Variables
var currInteraction:InteractionMaster.Type = InteractionMaster.Type.NULL;

func Initialise(biomeType:Biome_Master.Type, interType:InteractionMaster.Type) -> void:

	# Initialise Compenents
	fader = $Fader;
	sprite = $"Interaction-Sprite";
	
	if interType == InteractionMaster.Type.NULL:
		
		match randi_range(0, 1):
			0:
				Set_Interaction(InteractionMaster.Type.NULL);
				return;
			1:
				Spawn_RandomInteraction(biomeType);

# [ 1 / 4 ] Functions: Spawning ----------------------------------------------------------------------------------------------------

func Spawn_RandomInteraction(biomeType:Biome_Master.Type) -> void:
	
	if biomeType == Biome_Master.Type.Water:
		Try_Spawn(biomeType, InteractionMaster.WaterInteractions().pick_random());
		return;
	
	Try_Spawn(biomeType, randi_range(1, InteractionMaster.Type.size() - 1));

func Try_Spawn(biomeType:Biome_Master.Type, interType:InteractionMaster.Type) -> void:
	
	if !Should_Spawn(interType):
			
		if InteractionMaster.InteractionsWith_IncreasingChance().has(interType):
			World.Increase_Chance(interType);
		
		Set_Interaction(InteractionMaster.Type.NULL);
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
				#InGameDebugger.Say("Spawn: Fish");
				return;
				
		InteractionMaster.Type.Boat:
			
			if biomeType == Biome_Master.Type.Water or World.Win_ImprobableRoll():
				Spawn_Interaction(interType, true);
				InGameDebugger.Say("Spawn: Boat");
				return;
			
	Set_Interaction(InteractionMaster.Type.NULL);
	return;

func Should_Spawn(interType:InteractionMaster.Type) -> bool:
	return randi_range(0, World.Get_Chance(interType)) == 0;

func Spawn_Interaction(interType:InteractionMaster.Type, resetChance:bool = false) -> void:
	Set_Interaction(interType);
	Update_Sprite(interType);
	Appear();
	if resetChance:
		World.Reset_Chance(interType);

	if World.TimeTick.is_connected(On_WorldTick):
		return;

	# Start updating on the next frame
	await get_tree().process_frame;

	World.TimeTick.connect(On_WorldTick);

# [ 2 / 4 ] Functions: Get Set Interaction ----------------------------------------------------------------------------------------------------

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
			sprite.region_rect.position = Vector2i(0, 1024);
		InteractionMaster.Type.Fish:
			sprite.region_rect.position = Vector2i(0, 1792);
		InteractionMaster.Type.Boat:
			sprite.region_rect.position = Vector2i(256, 1536);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

# [ 4 / 4 ] Functions: Grid Position ----------------------------------------------------------------------------------------------------

func On_WorldTick() -> void:
	
	var surroundings:Array[Vector2i] = GridPos_Utils.GridPositions_Around(Get_GridPosition(), 1, true);
	surroundings = GridPos_Utils.Remove_Empty(surroundings);
	
	match(currInteraction):
		InteractionMaster.Type.Fish:
			Update_Fish(surroundings);
		InteractionMaster.Type.NULL:
			pass;

func Update_Fish(surroundings:Array[Vector2i]) -> void:

	var shouldMove:bool = randi_range(0, 1);
	
	if !shouldMove:
		return;

	var waters:Array[Vector2i] = [];
	
	for i in surroundings.size():
		
		var biomeObject:Object = World.Get_BiomeObject(surroundings[i]);
		
		if biomeObject.Get_BiomeType() != Biome_Master.Type.Water:
			continue;
		if biomeObject.Get_Interaction() != InteractionMaster.Type.NULL:
			continue;
		
		waters.append(surroundings[i]);
	
	if waters.size() == 0:
		return;
	
	var targPos:Vector2i = waters.pick_random();
	
	Set_Interaction(InteractionMaster.Type.NULL);
	Vanish(4);
	World.Get_BiomeObject(targPos).Spawn_Interaction(InteractionMaster.Type.Fish);

func Get_GridPosition() -> Vector2i:
	return get_parent().Get_GridPosition();
