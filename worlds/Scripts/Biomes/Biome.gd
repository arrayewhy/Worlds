extends Node2D;

# Components
var biomeSprite:Sprite2D;
var interaction:Node;
# Variables
var type:Biome_Master.Type;
var gridPos:Vector2i;
const rotRandLimit:float = .05;
const posRandLimit:float = 8;

func Initialise(gPos:Vector2i, biomeType:Biome_Master.Type) -> void:
	
	gridPos = gPos;
	
	if !biomeSprite:
		biomeSprite = $"Biome-Sprite";
	
	MultiFader.FadeTo_Opaque(biomeSprite, 2, true);
	
	# A bit of Visual Styling
	biomeSprite.rotate(randf_range(-rotRandLimit, rotRandLimit));
	biomeSprite.position += Vector2(randf_range(-posRandLimit, posRandLimit), randf_range(-posRandLimit, posRandLimit));
	#InGameDebugger.Say(position)

	biomeSprite.modulate.v = randf_range(.9, 1);
	
	match biomeType:
		Biome_Master.Type.Earth:
			Prep_Earth();
		Biome_Master.Type.Grass:
			Prep_Grass();
		Biome_Master.Type.Water:
			Prep_Water();
		#Biome_Master.Type.Stone:
			#Prep_Stone();
		_:
			InGameDebugger.Warn("Failed to Initialise Biome: No type specified.");
			
	Check_Surroundings();
		
func Check_Surroundings() -> void:
	if GridPos_Utils.Empties_Around(gridPos, 1, true).size() == 0:
		return;

	#if type != Biome_Master.Type.Water:
		#return;
	
	World.TimeTick.connect(On_TimeTick);
		
func On_TimeTick() -> void:
	
	var dist:float = gridPos.distance_to(World.PlayerGridPos());
	
	if dist >= 3:
		#biomeSprite.modulate.a = 0.5; # PRETTY WATER DEPTHS (Refer to Notes)
		return;
		
	#biomeSprite.modulate.a = 1; # PRETTY WATER DEPTHS (Refer to Notes)
	
	if GridPos_Utils.Empties_Around(gridPos, 1, true).size() > 0:
		return;

	match type:
		
		Biome_Master.Type.Water:

			if !Biome_Master.Surrounding_Biomes(gridPos, 1, true).has(Biome_Master.Type.Water):
				MultiFader.FadeTo_Trans(biomeSprite);
				Biome_Master.SpawnBiome(gridPos, Biome_Master.RandomBiomeType_Land(), get_parent(), Interaction_Master.Type.NULL);
				# HOTFIX
				await get_tree().create_timer(2).timeout;
				queue_free();
				#World.TimeTick.connect(On_TimeTick_QueueFree);
				
			#else: # PRETTY WATER DEPTHS (Refer to Notes)
				#biomeSprite.modulate.a = 0.25; # PRETTY WATER DEPTHS (Refer to Notes)

		_: # Landed biomes stranded in water
			
			var surroundingBiomes:Array[Biome_Master.Type] = Biome_Master.Surrounding_Biomes(gridPos, 1, true);
			if surroundingBiomes.count(Biome_Master.Type.Water) < 8:
				return;
				
			MultiFader.FadeTo_Trans(biomeSprite);
			Biome_Master.SpawnBiome(gridPos, Biome_Master.Type.Water, get_parent(), Interaction_Master.Type.NULL);
			# HOTFIX
			await get_tree().create_timer(2).timeout;
			queue_free();
			#World.TimeTick.connect(On_TimeTick_QueueFree);
	
	World.TimeTick.disconnect(On_TimeTick);

#func On_TimeTick_QueueFree() -> void:
	#World.TimeTick.disconnect(On_TimeTick_QueueFree);
	#queue_free();

# Functions: Biome Type ----------------------------------------------------------------------------------------------------

func Get_BiomeType() -> Biome_Master.Type:
	return type;

func Prep_Earth() -> void:
	type = Biome_Master.Type.Earth;
	biomeSprite.region_rect.position = Vector2i(256, 0);
	
func Prep_Grass() -> void:
	type = Biome_Master.Type.Grass;
	biomeSprite.region_rect.position = Vector2i(768, 0);
	
func Prep_Water() -> void:
	type = Biome_Master.Type.Water;
	biomeSprite.region_rect.position = Vector2i(0, 0);

#func Prep_Stone() -> void:
	#type = Biome_Master.Type.Stone;
	#biomeSprite.region_rect.position = Vector2i(512, 0);

# Functions: Interactions ----------------------------------------------------------------------------------------------------

func Initialise_Interaction(biomeType:Biome_Master.Type, interType:Interaction_Master.Type = Interaction_Master.Type.NULL) -> void:
	if !interaction:
		interaction = $"Interaction";
	interaction.Initialise(biomeType, interType);

func Spawn_Interaction(interType:Interaction_Master.Type) -> void:
	interaction.Spawn(interType);

func Get_Interaction() -> Interaction_Master.Type:
	return interaction.Get_Interaction();

# Functions: Grid Position ----------------------------------------------------------------------------------------------------

func Get_GridPosition() -> Vector2i:
	return gridPos;
