extends Node;

func _ready() -> void:
	World.TimeTick.connect(On_WorldTick);

func On_WorldTick() -> void:
	if get_parent().Get_Interaction() == InteractionMaster.Type.NULL:
		return;
		
	match(get_parent().Get_Interaction()):
		InteractionMaster.Type.Fish:
			Update_Fish();

func Update_Fish() -> void:

	var gPos:Vector2i = get_parent().Get_GridPosition();
	var surroundings:Array[Vector2i] = GridPos_Utils.Occupieds_Around(gPos, 1, true);

	if surroundings.size() == 0:
		return;

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
	
	get_parent().Set_Interaction(InteractionMaster.Type.NULL);
	get_parent().Vanish(4);
	
	World.Get_BiomeObject(targPos).Spawn_Interaction(InteractionMaster.Type.Fish);
