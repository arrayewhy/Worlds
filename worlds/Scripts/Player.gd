extends Node2D;

#@onready var biomeSpawner = $"Biome-Spawner";

@onready var mover:Node = $Mover;

@export var hover:Node;

@export var camMover:Node;

var initGridPos := Vector2i(0,0);
var currGridPos:Vector2i;

var moving:bool;

func _ready() -> void:
	currGridPos = initGridPos;
	World.SpawnBiomes_Around(currGridPos);

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("Enter"):
		#AudioMaster.PlaySFX_DogBark(position);

func _unhandled_key_input(event: InputEvent) -> void:
	
	var inputDir:Vector2i = Vector2i.ZERO;
	
	# Move and Spawn Repeater
	
	if event.is_action_pressed("One"):
		hover.set_process(false);
		RandomReveal(inputDir, 5000);
		return;
	
	# Normal Player Move and Biome Spawn
	
	inputDir = Get_DirectionInput(event);
	if inputDir != Vector2i(0,0):
		
		# Blocked by Water
		#var nextGPos:Vector2i = currGridPos + inputDir;
		#if Biome_Master.Get_BiomeType(nextGPos) == Biome_Master.Type.Water:
			#var surroundingBiomes:Array = Biome_Master.Surrounding_Biomes(nextGPos, 1);
			#if !surroundingBiomes.has(Biome_Master.Type.Earth) and !surroundingBiomes.has(Biome_Master.Type.Grass):
				#return;
		
		if moving:
			return;
		
		MovePlayer_And_SpawnBiomes(inputDir);
		World.Roll_Dice();
		return;
	
func Get_DirectionInput(event:InputEvent) -> Vector2i:
	if event.is_action("Up"):
		return Vector2i.UP;
	if event.is_action("Down"):
		return Vector2i.DOWN;
	if event.is_action("Left"):
		return Vector2i.LEFT;
	if event.is_action("Right"):
		return Vector2i.RIGHT;
	return Vector2i.ZERO;

func MovePlayer_And_SpawnBiomes(inputDir:Vector2i) -> void:
	
	moving = true;
	
	mover.Done.connect(On_Mover_Done);
	
	var prevGridPos = currGridPos;
	# Update Current Grid Position
	currGridPos += inputDir;
	# Spawn Biomes around new position
	World.SpawnBiomes_AroundPlayer(currGridPos, prevGridPos);
	var targPos = position + Vector2(inputDir) * World.CellSize();
	# Move Player
	mover.StartMove(targPos);
	#position = targPos;
	# Move Camera
	camMover.StartMove(targPos);
	
	await get_tree().process_frame;
	World.Advance_Time();

func On_Mover_Done() -> void:
	moving = false;
	mover.Done.disconnect(On_Mover_Done);

# Functions: Debug ----------------------------------------------------------------------------------------------------

func RandomReveal(inputDir:Vector2i, repetitions:int = 1000) -> void:
	
	var gPos:Vector2i = currGridPos
	
	for i in repetitions:
		
		inputDir = Get_RandDirection();
		
		#var prevGridPos = currGridPos;
		# Update Current Grid Position
		gPos += inputDir;
		# Spawn Biomes around new position
		World.SpawnBiomes_AroundPlayer(gPos, gPos);
		#var targPos = position + Vector2(inputDir) * World.CellSize();
		# Move Player
		#mover.StartMove(targPos);
		#position = targPos;
		# Move Camera
		#camMover.StartMove(targPos);
		
		await get_tree().process_frame;
		World.Advance_Time();
		
	hover.set_process(true);
	InGameDebugger.Say(World.DiscoveredBiomes().size());

func Get_RandDirection() -> Vector2i:
	match randi_range(0, 3):
			0:
				return Vector2i.UP;
			1:
				return Vector2i.DOWN;
			2:
				return Vector2i.LEFT;
			3:
				return Vector2i.RIGHT;
			_:
				return Vector2i.ZERO;
