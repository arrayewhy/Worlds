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
	
	# A bit of Visual Styling
	biomeSprite.rotate(randf_range(-rotRandLimit, rotRandLimit));
	biomeSprite.position += Vector2(randf_range(-posRandLimit, posRandLimit), randf_range(-posRandLimit, posRandLimit));
	#InGameDebugger.Say(position)

	#biomeSprite.modulate.v = randf_range(.9, 1);
	
	match biomeType:
		Biome_Master.Type.Earth:
			Prep_Earth();
			MultiFader.FadeTo_Opaque(biomeSprite, 2, true);
		Biome_Master.Type.Grass:
			Prep_Grass();
			MultiFader.FadeTo_Opaque(biomeSprite, 2, true);
		Biome_Master.Type.Water:
			Prep_Water();
			MultiFader.FadeTo_Alpha(biomeSprite, .2, 0, 1);
		#Biome_Master.Type.Stone:
			#Prep_Stone();
		_:
			InGameDebugger.Warn("Failed to Initialise Biome: No type specified.");
			
	#Check_Surroundings();
		
func Check_Surroundings() -> void:
	if GridPos_Utils.Empties_Around(gridPos, 1, true).size() == 0:
		
		if type == Biome_Master.Type.Water:
			print(true)
			MultiFader.FadeTo_Alpha(biomeSprite, 1, biomeSprite.modulate.a, 1);
		
		return;

	#if type != Biome_Master.Type.Water:
		#return;
	
	World.TimeTick.connect(On_TimeTick);
		
func On_TimeTick() -> void:
	
	var dist:float = gridPos.distance_to(World.PlayerGridPos());
	
	#if dist >= 3:
		#biomeSprite.modulate.a = 0.5; # PRETTY WATER DEPTHS (Refer to Notes)
		#return;
		
	#biomeSprite.modulate.a = 1; # PRETTY WATER DEPTHS (Refer to Notes)
	
	if GridPos_Utils.Empties_Around(gridPos, 1, true).size() > 0:
		return;

	# Make Y-Sort put the newly spawned biome behind the existing biome
	var newBiomeOffset := Vector2(0, -10);

	var surroundingBiomes:Array[Biome_Master.Type] = Biome_Master.Surrounding_Biomes(gridPos, 1, true);
	var waters:int = surroundingBiomes.count(Biome_Master.Type.Water);

	match type:
		
		Biome_Master.Type.Water: # Water stranded on Land

			if !surroundingBiomes.has(Biome_Master.Type.Water):
				
				Biome_Master.SpawnBiome(gridPos, Biome_Master.RandomBiomeType_Land(), get_parent(), \
				Interaction_Master.Type.NULL, Vector2(0, -10));
				interaction.Disable();
				FadeAndDelete(biomeSprite);
				
			else:
			
				# PRETTY WATER DEPTHS (Refer to Notes)
				
				var targDepth:float = 1 - (waters * 0.1);
				MultiFader.FadeTo_Alpha(biomeSprite, targDepth, biomeSprite.modulate.a, .5);

		_: # Landed biomes stranded in Water
			
			if waters < 8:
				if waters > 6:
					var tween:Tween = create_tween();
					tween.tween_property(biomeSprite, "modulate", Color(1, 1, 1, .65), 4);
			else:
				var tween:Tween = create_tween();
				tween.tween_property(biomeSprite, "modulate", Color(1, 1, 1, .4), 4);
			#Biome_Master.SpawnBiome(gridPos, Biome_Master.Type.Water, get_parent(), Interaction_Master.Type.NULL, newBiomeOffset);
			#interaction.Disable();
			#FadeAndDelete(biomeSprite);
	
	World.TimeTick.disconnect(On_TimeTick);

func FadeAndDelete(spr:Sprite2D) -> void:
	var tween:Tween = create_tween();
	tween.tween_property(spr, "modulate", Color.TRANSPARENT, 4);
	tween.tween_callback(queue_free);

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
	
func Is_Interaction_Disabled() -> bool:
	return interaction.Is_Disabled();

# Functions: Grid Position ----------------------------------------------------------------------------------------------------

func Get_GridPosition() -> Vector2i:
	return gridPos;
