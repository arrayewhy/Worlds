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
	#position += rand;
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

func Initialise_Interaction(biomeType:Biome_Master.Type, interType:InteractionMaster.Type = InteractionMaster.Type.NULL) -> void:
	if !interaction:
		interaction = $"Interaction";
	interaction.Initialise(biomeType, interType);

func Spawn_Interaction(interType:InteractionMaster.Type) -> void:
	interaction.Spawn_Interaction(interType);

func Get_Interaction() -> InteractionMaster.Type:
	return interaction.Get_Interaction();

# Functions: Grid Position ----------------------------------------------------------------------------------------------------

func Get_GridPosition() -> Vector2i:
	return gridPos;
