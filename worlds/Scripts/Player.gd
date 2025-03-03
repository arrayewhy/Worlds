extends Node2D;

@onready var biomeSpawner = $"Biome-Spawner";

@onready var mover:Node = $Mover;
@onready var playerSpr:Sprite2D = $Sprite2D;

@export var hover:Node;

@export var microView:CanvasLayer;
@export var camMover:Node;

const initGridPos := Vector2i(0,0);
const movementInterval:float = 0.5;

var currGridPos:Vector2i;

var moving:bool;
var insideInteraction:bool;

var timeSkips:int;

signal EnterInteraction(state);

func _ready() -> void:
	currGridPos = initGridPos;
	World.SpawnBiomes_Around(currGridPos, 2);

func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Cancel"):
		PauseMenu.Toggle_Pause(name);
	
	# Move and Spawn Repeater
	if event.is_action_pressed("One"):
		hover.set_process(false);
		RandomReveal(5000);
		return;
	
	if moving:
		return;
	
	var inputDir:Vector2i = Get_DirectionInput(event);
	
	if inputDir == Vector2i(0,0):
		return;
	
	#World.UpdateBiases_AccordingTo_DistFromCenter(inputDir);
	
	# Time Skip from spending more time moving through forests
	
	#if timeSkips > 0:
		#InGameDebugger.Say("Time Skip");
		#timeSkips -= 1;
		#World.Advance_Time();
		##moving = true;
		##await get_tree().create_timer(movementInterval).timeout;
		##moving = false;
		#return;
	
	# Interaction Fade
	
	var nextGPos:Vector2i = currGridPos + inputDir;
		
	var nextInteraction = Interaction_Master.Get_InteractionType(nextGPos);
	
	if nextInteraction == Interaction_Master.Type.Forest:
		if !insideInteraction:
			MultiFader.FadeTo_Trans(playerSpr);
			insideInteraction = true;
			EnterInteraction.emit(true);
		#timeSkips = 1;
	elif nextInteraction != Interaction_Master.Type.Forest:
		if insideInteraction:
			MultiFader.FadeTo_Opaque(playerSpr);
			insideInteraction = false;
			EnterInteraction.emit(false);
		
	# Move and Spawn
		
	Do_PlayerMove_BiomeSpawn_InterractionSpawn(inputDir);
	
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

func Do_PlayerMove_BiomeSpawn_InterractionSpawn(inputDir:Vector2i, moveCam:bool = true) -> void:
	
	# Blocked by Water
	#if Biome_Master.Get_BiomeType(nextGPos) == Biome_Master.Type.Water:
		#var surroundingBiomes:Array = Biome_Master.Surrounding_Biomes(nextGPos, 1);
		#if !surroundingBiomes.has(Biome_Master.Type.Earth) and !surroundingBiomes.has(Biome_Master.Type.Grass):
			#return;
	
	moving = true;
	
	#var prevGridPos = currGridPos;
	# Update Current Grid Position
	currGridPos += inputDir;
	
	var predefinedLocation:Biome_Master.Predefined = biomeSpawner.Predefined_Location(inputDir, currGridPos);
	
	# Spawn Biomes around new position
	World.SpawnBiomesAround_Player(currGridPos);
	
	# Move Player
	var targPos = position + Vector2(inputDir) * World.CellSize();
	mover.StartMove(targPos);
	#position = targPos;
	
	# Move Camera
	if moveCam:
		camMover.StartMove(targPos);
		
	# Prevent Interactions from Updating as soon as they Spawn by advancing time in the next frame.
	await get_tree().process_frame;
	World.Advance_Time();
	
	# Movement Interval
	await mover.Done;
	moving = false;
	#await get_tree().create_timer(movementInterval).timeout;
	#moving = false;
	
	
	World.Roll_Dice();

# Functions: Debug ----------------------------------------------------------------------------------------------------

func RandomReveal(repetitions:int = 1000) -> void:
	
	var inputDir:Vector2i;
	
	var gPos:Vector2i = currGridPos
	
	for i in repetitions:
		
		inputDir = Get_RandDirection();
		gPos += inputDir;
		# Spawn Biomes around new position
		World.SpawnBiomes_AroundPlayer(gPos, gPos);
		
		await get_tree().process_frame;
		World.Advance_Time();
		
		await get_tree().create_timer(1).timeout;
		
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
