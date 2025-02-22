extends Node;

func On_WorldTick() -> void:
	match(get_parent().Get_Interaction()):
		InteractionMaster.Type.Fish:
			Update_Fish();

func Update_Fish() -> void:
	
	InGameDebugger.Say(str("Updating: ", InteractionMaster.Type.keys()[get_parent().Get_Interaction()]), true);
	
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
	
	var targGPos:Vector2i = waters.pick_random();
	
	get_parent().Disable_Interaction(4);
	
	Disconnect_TimeTick();
	
	# Spawn Interaction through Target Biome Object
	World.Get_BiomeObject(targGPos).Spawn_Interaction(InteractionMaster.Type.Fish);

# Functions: Signals ----------------------------------------------------------------------------------------------------

func Connect_TimeTick() -> void:
	World.TimeTick.connect(On_WorldTick);

func Disconnect_TimeTick() -> void:
	World.TimeTick.disconnect(On_WorldTick);
