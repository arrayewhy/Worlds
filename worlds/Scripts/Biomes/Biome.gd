extends Node2D;

# Components
var biomeSprite:Sprite2D;
var interaction:Node;
# Variables
var type:Biome_Master.Type;
var gridPos:Vector2i;
const rotRandLimit:float = .05;
const posRandLimit:float = 8;

var _fading:bool;

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
		Biome_Master.Type.Grass:
			Prep_Grass();
		Biome_Master.Type.Water:
			Prep_Water();
		Biome_Master.Type.Stone:
			Prep_Stone();
		Biome_Master.Type.DARKNESS:
			Prep_DARKNESS();
		_:
			InGameDebugger.Warn("Failed to Initialise Biome: No type specified.");
			
	Fade_Alpha(biomeSprite, 1, 1, 0);
		
func Check_Surroundings() -> void:

	var surroundingBiomes:Array[Biome_Master.Type] = Biome_Master.Surrounding_Biomes(gridPos, 1, true, false);
	var waters:int = surroundingBiomes.count(Biome_Master.Type.Water);
	var targDepth:float = 1 - (waters * .1);

	# If surrounding biomes are full
	if GridPos_Utils.Empties_Around(gridPos, 1, true).size() == 0:
		
		# Water Biome
		if type == Biome_Master.Type.Water:
			Fade_Alpha(biomeSprite, targDepth, waters, 0);
		
		# Land Biomes
		else:
			if waters == 7:
					Fade_Alpha(biomeSprite, .65, 4, 1);
			else:
				Fade_Alpha(biomeSprite, .4, 4, 1);
		
		return;
	
	# If there are Empties around:
	# Both Land and Water should be darker, deterministically
	if type == Biome_Master.Type.Water:
		Fade_Alpha(biomeSprite, .25, 4, 0);
	else:
		Fade_Alpha(biomeSprite, .75, 1, 0);
	
	# Begin to check for new nearby biomes on Time Tick
	if !World.TimeTick.is_connected(On_TimeTick):
		World.TimeTick.connect(On_TimeTick);
		
func On_TimeTick() -> void:
	
	var dist:float = gridPos.distance_to(World.PlayerGridPos());
	
	if dist >= 3:
		#biomeSprite.modulate.a = 0.5; # PRETTY WATER DEPTHS (Refer to Notes)
		return;
	
	if GridPos_Utils.Empties_Around(gridPos, 1, true).size() > 0:
		return;

	# Make Y-Sort put the newly spawned biome behind the existing biome
	#var newBiomeOffset := Vector2(0, -10);

	var surroundingBiomes:Array[Biome_Master.Type] = Biome_Master.Surrounding_Biomes(gridPos, 1, true, false);
	var waters:int = surroundingBiomes.count(Biome_Master.Type.Water);

	match type:
		
		Biome_Master.Type.Water: # Water stranded on Land

			if !surroundingBiomes.has(Biome_Master.Type.Water):
				
				Biome_Master.SpawnBiome(gridPos, Biome_Master.RandomBiomeType_Land(), get_parent(), \
				Interaction_Master.Type.NULL, Vector2(0, -10));
				interaction.Disable();
				FadeOut_And_Delete(biomeSprite);
				
			else: # If there is water nearby
				# CULPRIT: Fade Issue
				var targDepth:float = 1 - (waters * .1);
				#Fade_Alpha(biomeSprite, targDepth, waters, biomeSprite.modulate.a);

		_: # Landed biomes stranded in Water
			
			var targDepth:float = 1 - (waters * .1);
			
			if waters >= 7:
				Fade_Alpha(biomeSprite, targDepth, 4, biomeSprite.modulate.a);
			else:
				Fade_Alpha(biomeSprite, targDepth, 4, 1);
	
	World.TimeTick.disconnect(On_TimeTick);

func FadeOut_And_Delete(spr:Sprite2D) -> void:
	var tween:Tween = create_tween();
	tween.tween_property(spr, "modulate", Color.TRANSPARENT, 4);
	tween.tween_callback(queue_free);

func Fade_Alpha(spr:Sprite2D, targAlpha:float, dur:float, startAlpha:float) -> void:
	if _fading:
		print_debug("Attempting to interrupt fade.")
	_fading = true;
	spr.modulate.a = startAlpha;
	var tween:Tween = create_tween();
	tween.tween_property(spr, "modulate", Color(1, 1, 1, targAlpha), dur);
	tween.tween_callback(SetFading_False);

func SetFading_False() -> void:
	_fading = false

# Functions: Biome Type ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

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
	
func Prep_Stone() -> void:
	type = Biome_Master.Type.Stone;
	biomeSprite.region_rect.position = Vector2i(512, 0);
	
func Prep_DARKNESS() -> void:
	type = Biome_Master.Type.DARKNESS;
	biomeSprite.region_rect.position = Vector2i(1792, 0);

# Functions: Interactions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

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

# Functions: Grid Position ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func Get_GridPosition() -> Vector2i:
	return gridPos;
