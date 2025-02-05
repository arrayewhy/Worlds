extends Node2D;

var biomeSprite:Sprite2D;
var interactionSpawner:Node;

var type:BiomeMaster.Type;

func Initialise(biomeType:BiomeMaster.Type) -> void:
	
	if !biomeSprite:
		biomeSprite = $"Biome-Sprite";
	
	# A bit of Visual Styling
	self.rotate(randf_range(-.05, .05));
	biomeSprite.modulate.v = randf_range(.9, 1);
	
	match biomeType:
		BiomeMaster.Type.Earth:
			Prep_Earth();
		BiomeMaster.Type.Grass:
			Prep_Grass();
		BiomeMaster.Type.Water:
			Prep_Water();
		_:
			InGameDebugger.Warn("Failed to Initialise Biome: No type specified.");

func Prep_Earth() -> void:
	type = BiomeMaster.Type.Earth;
	biomeSprite.region_rect.position = Vector2i(256, 0);
	
func Prep_Grass() -> void:
	type = BiomeMaster.Type.Grass;
	biomeSprite.region_rect.position = Vector2i(768, 0);
	
func Prep_Water() -> void:
	type = BiomeMaster.Type.Water;
	biomeSprite.region_rect.position = Vector2i(0, 0);

func Initialise_Interaction(biomeType:BiomeMaster.Type) -> void:
	if !interactionSpawner:
		interactionSpawner = $"Interaction-Spawner";
	interactionSpawner.Initialise(biomeType);
