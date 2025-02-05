extends Node;

var sprite:Sprite2D;

var currInteraction:InteractionMaster.Type;

func Initialise(biomeType:BiomeMaster.Type) -> void:
	
	if !sprite:
		sprite = $"Interaction-Sprite";
		
	match randi_range(0, InteractionMaster.Type.size()):
		0:
			currInteraction = InteractionMaster.Type.NULL;
		1:
			TrySpawn_Dog(biomeType);
		
	if currInteraction == InteractionMaster.Type.NULL:
		sprite.hide();
		return;
		
	sprite.show();

func Get_Interaction() -> InteractionMaster.Type:
	return currInteraction;

func TrySpawn_Dog(biomeType:BiomeMaster.Type) -> void:
	
	if randi_range(0, World.GetChance_Dog()) != 0:
		World.IncreaseChance_Dog();
		InGameDebugger.Say(World.chance_dog);
		currInteraction = InteractionMaster.Type.NULL;
		return;
	
	if biomeType == BiomeMaster.Type.Water and randi_range(0, World.Get_MaxChance()) != 0:
		return;

	Spawn_Dog();

func Spawn_Dog() -> void:
	currInteraction = InteractionMaster.Type.Dog;
	World.ResetChance_Dog();
	InGameDebugger.Say("Doggo sighted!");

func Spawn_WaterDog() -> void:
	currInteraction = InteractionMaster.Type.Dog;
	World.ResetChance_Dog();
	InGameDebugger.Say("Doggo overboard!");
