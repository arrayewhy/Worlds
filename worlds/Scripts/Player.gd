extends Node2D;

@onready var mover:Node = $Mover;
@onready var playerSpr:Sprite2D = $"Player-Sprite";
@onready var biomeSpawner:Node = $"Biome-Spawner";
@onready var worldTemplate:Node = $"World-Template";

#@export var hover:Node;

@export var microView:CanvasLayer;
@export var camMover:Node;

const initGridPos := Vector2i(0,0);
const movementInterval:float = 0.5;

var currGridPos:Vector2i;
var revealerGPos := Vector2i.ZERO;
var revealerDelay:float = 2;

var moving:bool;
var insideInteraction:bool;

var timeSkips:int;

var count:int = 0;

func _ready() -> void:
	currGridPos = initGridPos;
	#World.SpawnBiomes_Around(currGridPos, 2);
	worldTemplate.SpawnBiomes_FromImage();

#func _process(delta: float) -> void:
	#
	#if revealerDelay > 0:
		#revealerDelay -= delta;
		#return;
	#revealerDelay = 2;
	#
	## Move and Spawn Repeater
	#RandomReveal();

func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Enter"):
		var targs:Array[Vector2i] = GridPos_Utils.GridPositions_Around(currGridPos, 5 + count, true);
		targs = GridPos_Utils.Remove_Occupied(targs);
		
		for gp in targs:
			if gp.distance_to(currGridPos) > 4 + count:
				continue;
			#Biome_Master.SpawnBiome(gp, Biome_Master.RandomBiomeType_Core(), biomeSpawner.biomeHolder, Interaction_Master.Type.NULL);
			biomeSpawner.SpawnRandomBiomes_Influenced(gp, 1, 2);
		
		count += 1;
		
	
	if event.is_action_pressed("Cancel"):
		PauseMenu.Toggle_Pause(name);
	
	if PauseMenu.Is_Paused():
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
	
	var nextGPos:Vector2i = currGridPos + inputDir;

	# Interaction Fade

	var nextInteraction = Interaction_Master.Get_InteractionType(nextGPos);
	
	if nextInteraction == Interaction_Master.Type.Forest:
		if !insideInteraction:
			MultiFader.FadeTo_Trans(playerSpr);
			insideInteraction = true;
		#timeSkips = 1;
	elif nextInteraction != Interaction_Master.Type.Forest:
		if insideInteraction:
			MultiFader.FadeTo_Opaque(playerSpr);
			insideInteraction = false;
	
	# LEFTOFF
	# Cannot walk onto DARKNESS
	if Biome_Master.Get_BiomeType(nextGPos) == Biome_Master.Type.DARKNESS:
		return;
	
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
	
	moving = true;
	
	#var prevGridPos = currGridPos;
	# Update Current Grid Position
	currGridPos += inputDir;
	
	if Biome_Master.Get_BiomeType(currGridPos) == Biome_Master.Type.Water:
		if !playerSpr.Is_Swim():
			playerSpr.ChangeTo_Swim();
	else:
		if !playerSpr.Is_Normal():
			playerSpr.ChangeTo_Normal();
	
	#var predefinedLocation:Biome_Master.Predefined = biomeSpawner.Predefined_Location(inputDir, currGridPos);
	
	# Spawn Biomes around new position
	World.SpawnBiomesAround_Player(currGridPos);
	
	# Move Player
	var targPos = position + Vector2(inputDir) * World.CellSize();
	mover.StartMove(targPos);
	#position = targPos;
	
	# Move Camera
	if moveCam:
		camMover.StartMove(targPos);
		
	## Prevent Interactions from Updating as soon as they Spawn by advancing time in the next frame.
	await get_tree().process_frame;
	World.Advance_Time();
	#
	## Movement Interval
	await mover.Done;
	moving = false;
	#await get_tree().create_timer(movementInterval).timeout;
	#moving = false;
	
	World.Roll_Dice();

# Functions: Debug ----------------------------------------------------------------------------------------------------

func RandomReveal() -> void:
	
	var dir:Vector2i = Get_RandDirection();

	dir = Get_RandDirection();
	revealerGPos += dir;
	# Spawn Biomes around new position
	World.SpawnBiomes_Around(revealerGPos, 1, 0);
	
	await get_tree().process_frame;
	World.Advance_Time();

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
