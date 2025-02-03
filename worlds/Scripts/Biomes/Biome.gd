extends Node;

var biomeSprite:Sprite2D;

@export var type:BiomeMaster.Type;

func Initialise(biomeType:BiomeMaster.Type) -> void:
	
	biomeSprite = $Sprite2D;
	
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
