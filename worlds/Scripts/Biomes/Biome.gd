extends Node;

var biomeSprite:Sprite2D;
var interactionSpawner:Node;

var type:BiomeMaster.Type;

func Initialise(biomeType:BiomeMaster.Type) -> void:
	
	if !biomeSprite:
		biomeSprite = $"Biome-Sprite";
	
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

func Set_Interaction(interType:InteractionMaster.Type) -> void:
	if !interactionSpawner:
		interactionSpawner = $"Interaction-Spawner";
	interactionSpawner.Set_Interaction(interType);
