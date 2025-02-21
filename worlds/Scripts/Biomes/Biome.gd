extends Node2D;

var biomeSprite:Sprite2D;
var interactionSpawner:Node;

var type:Biome_Master.Type;

func Initialise(biomeType:Biome_Master.Type) -> void:
	
	if !biomeSprite:
		biomeSprite = $"Biome-Sprite";
	
	# A bit of Visual Styling
	self.rotate(randf_range(-.05, .05));
	biomeSprite.modulate.v = randf_range(.9, 1);
	
	match biomeType:
		Biome_Master.Type.Earth:
			Prep_Earth();
		Biome_Master.Type.Grass:
			Prep_Grass();
		Biome_Master.Type.Water:
			Prep_Water();
		_:
			InGameDebugger.Warn("Failed to Initialise Biome: No type specified.");

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

# Functions: Interactions ----------------------------------------------------------------------------------------------------

func Initialise_Interaction(gPos:Vector2i, biomeType:Biome_Master.Type, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	if !interactionSpawner:
		interactionSpawner = $"Interaction-Spawner";
	interactionSpawner.Initialise(gPos, biomeType, interType);

func Get_Interaction() -> InteractionMaster.Type:
	return interactionSpawner.Get_Interaction();
