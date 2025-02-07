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
		Try_Spawn(gPos, biomeType, InteractionMaster.Type.Fish);
		return;
	
	Try_Spawn(gPos, biomeType, randi_range(1, InteractionMaster.Type.size() - 1));

func Try_Spawn(gPos:Vector2i, biomeType:BiomeMaster.Type, interType:InteractionMaster.Type) -> void:
	
	if !Should_Spawn(interType):
		
		if interType != InteractionMaster.Type.Fish:
			World.Increase_Chance(interType);
		Set_None();
		return;
	
	match interType:
		
		InteractionMaster.Type.Dog:
		
			if biomeType == BiomeMaster.Type.Water:
				if !World.Win_ImprobableRoll():
					World.Increase_Chance(interType);
					Set_None();
					return;
				
			Spawn_Interaction(gPos, interType);
			World.Reset_Chance(interType);
			InGameDebugger.Say("Spawn: Dog");
			return;
			
		InteractionMaster.Type.Fish:
			
			if biomeType == BiomeMaster.Type.Water:
				Spawn_Interaction(gPos, interType);
				InGameDebugger.Say("Spawn: Fish");
				return;
			
			# Land Fish
			if !World.Win_ImprobableRoll():
				Set_None();
				return;

func Should_Spawn(interType:InteractionMaster.Type) -> bool:
	return randi_range(0, World.Get_Chance(interType)) == 0;

func Spawn_Interaction(gPos:Vector2i, interType:InteractionMaster.Type) -> void:
	currInteraction = interType;
	Update_Sprite(interType);
	World.Record_Interaction(gPos, interType);

func Update_Sprite(interType:InteractionMaster.Type) -> void:
	match interType:
		InteractionMaster.Type.Dog:
			sprite.region_rect.position = Vector2i(0, 2048);
		InteractionMaster.Type.Fish:
			sprite.region_rect.position = Vector2i(0, 1792);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

func Set_None() -> void:
	currInteraction = InteractionMaster.Type.NULL;
	sprite.hide();
