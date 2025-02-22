extends Node;

func _ready() -> void:
	World.TimeTick.connect(On_WorldTick);
	await get_tree().process_frame;
	
	#InGameDebugger.Say(get_incoming_connections().size());
	#for i in get_incoming_connections().size():
		#InGameDebugger.Say(get_incoming_connections()[i].callable);
	#InGameDebugger.Say("\n-\n");

func On_WorldTick() -> void:
	if get_parent().Get_Interaction() == InteractionMaster.Type.NULL:
		return;
		
	# Why is this firing multiple times?
		
	InGameDebugger.Say("Update", true);
	match(get_parent().Get_Interaction()):
		InteractionMaster.Type.Fish:
			Update_Fish();

func Update_Fish() -> void:

	var gPos:Vector2i = get_parent().Get_GridPosition();
	var surroundings:Array[Vector2i] = GridPos_Utils.Occupieds_Around(gPos, 1, true);

	if surroundings.size() == 0:
		return;

	# Decide if the fish should move.
	#if randi_range(0, 1) == 0:
		#return;

	var waters:Array[Vector2i] = [];
	
	for i in surroundings.size():
		
		var biomeObject:Object = World.Get_BiomeObject(surroundings[i]);
		
		if biomeObject.Get_BiomeType() != Biome_Master.Type.Water:
			continue;
		if biomeObject.Get_Interaction() != InteractionMaster.Type.NULL:
			continue;
		if surroundings[i] == World.PlayerGridPos():
			continue;
		
		waters.append(surroundings[i]);
	
	if waters.size() == 0:
		return;
	
	var targPos:Vector2i = waters.pick_random();
	#InGameDebugger.Say(str(get_parent().Get_GridPosition(), targPos), true)
	#InGameDebugger.Say("\n")
	get_parent().Set_Interaction(InteractionMaster.Type.NULL);
	get_parent().Vanish(4);
	
	World.Get_BiomeObject(targPos).Spawn_Interaction(InteractionMaster.Type.Fish);
