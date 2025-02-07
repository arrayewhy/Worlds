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
	Try_Spawn(gPos, biomeType, randi_range(1, InteractionMaster.Type.size() - 1));

func Try_Spawn(gPos:Vector2i, biomeType:BiomeMaster.Type, interType:InteractionMaster.Type) -> void:
	
	match interType:
		
		InteractionMaster.Type.Dog:
			
			if !Should_Spawn(InteractionMaster.Type.Dog):
				World.Increase_Chance(InteractionMaster.Type.Dog);
				Set_None();
				return;
		
			if biomeType == BiomeMaster.Type.Water:
				if Win_ImprobableRoll():
					Spawn_Interaction(gPos, InteractionMaster.Type.Dog);
					return;
				else:
					World.Increase_Chance(InteractionMaster.Type.Dog);
					Set_None();
					return;
					
			Spawn_Interaction(gPos, InteractionMaster.Type.Dog);
			return;

func Win_ImprobableRoll() -> bool:
	return randi_range(0, World.Get_MaxChance()) == 0;

func Should_Spawn(interType:InteractionMaster.Type) -> bool:
	return randi_range(0, World.Get_Chance(interType)) == 0;

func Spawn_Interaction(gPos:Vector2i, interType:InteractionMaster.Type) -> void:
	currInteraction = interType;
	Update_Sprite(interType);
	World.Reset_Chance(interType);
	World.Record_Interaction(gPos, interType);

func Update_Sprite(interType:InteractionMaster.Type) -> void:
	match interType:
		InteractionMaster.Type.Dog:
			sprite.region_rect.position = Vector2i(0, 2048);
		_:
			InGameDebugger.Warn(str("Failed to update sprite, Interaction: "), interType);

func Set_None() -> void:
	currInteraction = InteractionMaster.Type.NULL;
	sprite.hide();
