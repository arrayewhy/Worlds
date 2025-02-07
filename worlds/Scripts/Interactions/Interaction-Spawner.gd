extends Node;

var sprite:Sprite2D;

var currInteraction:InteractionMaster.Type;

func Initialise(gPos:Vector2i, biomeType:BiomeMaster.Type, interType:InteractionMaster.Type) -> void:
	
	if !sprite:
		sprite = $"Interaction-Sprite";
	
	if interType == InteractionMaster.Type.NULL:
		
		match randi_range(0, 1):
			0:
				currInteraction = InteractionMaster.Type.NULL;
				sprite.hide();
				return;
			1:
				Spawn_RandomInteraction(gPos, biomeType);

func Get_Interaction() -> InteractionMaster.Type:
	return currInteraction;

func Spawn_RandomInteraction(gPos:Vector2i, biomeType:BiomeMaster.Type) -> void:
	
	if biomeType == BiomeMaster.Type.Water:
		
		var waterInteractions:Array[InteractionMaster.Type] = [InteractionMaster.Type. Fish, InteractionMaster.Type.Boat];
		
		Try_Spawn(gPos, biomeType, waterInteractions.pick_random());
		
		return;
	
	Try_Spawn(gPos, biomeType, randi_range(1, InteractionMaster.Type.size() - 1));

func Try_Spawn(gPos:Vector2i, biomeType:BiomeMaster.Type, interType:InteractionMaster.Type) -> void:
	
	if !Should_Spawn(interType):
		
		if interType == InteractionMaster.Type.Dog or interType == InteractionMaster.Type.Boat:
			World.Increase_Chance(interType);
			
		Set_None();
		return;
	
	match interType:
		
		InteractionMaster.Type.Dog:
		
			if biomeType == BiomeMaster.Type.Water and !World.Win_ImprobableRoll():
					Set_None();
					return;
				
			Spawn_Interaction(gPos, interType, true);
			InGameDebugger.Say("Spawn: Dog");
			return;
			
		InteractionMaster.Type.Fish:
			
			if biomeType == BiomeMaster.Type.Water or World.Win_ImprobableRoll():
				Spawn_Interaction(gPos, interType);
				InGameDebugger.Say("Spawn: Fish");
				return;
			
			Set_None();
			return;
				
		InteractionMaster.Type.Boat:
			
			if biomeType == BiomeMaster.Type.Water or World.Win_ImprobableRoll():
				Spawn_Interaction(gPos, interType, true);
				InGameDebugger.Say("Spawn: Boat");
				return;
			
			Set_None();
			return;

func Should_Spawn(interType:InteractionMaster.Type) -> bool:
	return randi_range(0, World.Get_Chance(interType)) == 0;

func Spawn_Interaction(gPos:Vector2i, interType:InteractionMaster.Type, resetChance:bool = false) -> void:
	currInteraction = interType;
	Update_Sprite(interType);
	World.Record_Interaction(gPos, interType);
	if resetChance:
		World.Reset_Chance(interType);

func Update_Sprite(interType:InteractionMaster.Type) -> void:
	match interType:
		InteractionMaster.Type.Dog:
			sprite.region_rect.position = Vector2i(0, 2048);
		InteractionMaster.Type.Fish:
			sprite.region_rect.position = Vector2i(0, 1792);
		InteractionMaster.Type.Boat:
			sprite.region_rect.position = Vector2i(256, 1536);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

func Set_None() -> void:
	currInteraction = InteractionMaster.Type.NULL;
	sprite.hide();
