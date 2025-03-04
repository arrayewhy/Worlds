extends Node2D;

@onready var mover:Node = $Mover;
@onready var playerSpr:Sprite2D = $"Player-Sprite";
@onready var biomeSpawner:Node = $"Biome-Spawner";
@onready var worldTemplates:Node = $"World-Templates";

#@export var hover:Node;

@export var microView:CanvasLayer;
@export var cam:Camera2D;
@export var camMover:Node;

const initGridPos := Vector2i(1, 13);
const movementInterval:float = 0.5;

var currGridPos:Vector2i;

var moving:bool;
var insideInteraction:bool;

var timeSkips:int;

func _ready() -> void:
	currGridPos = initGridPos;
	self.position = currGridPos * World.CellSize();
	cam.position = self.position;
	#World.SpawnBiomes_Around(currGridPos, 2);
	worldTemplates.SpawnBiomes_FromImage(0);

func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Cancel"):
		PauseMenu.Toggle_Paused(name);
	
	if PauseMenu.Is_Paused():
		return;
	
	if moving:
		return;
	
	var inputDir:Vector2i = Get_DirectionInput(event);
	
	if inputDir == Vector2i(0,0):
		return;
	
	#World.UpdateBiases_AccordingTo_DistFromCenter(inputDir);
	
	var nextGPos:Vector2i = currGridPos + inputDir;

	FadeIntoInteraction(nextGPos);
	
	# Cannot walk onto DARKNESS
	if Biome_Master.Get_BiomeType(nextGPos) == Biome_Master.Type.DARKNESS:
		return;
	
	MovePlayer_Then_Spawn_Biomes_And_Interactions(inputDir);

# Functions [ 1 / 4 ] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func MovePlayer_Then_Spawn_Biomes_And_Interactions(inputDir:Vector2i, moveCam:bool = true) -> void:
	
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

# Functions [ 2 / 4 ]: Debug ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func RandomReveal(revealerGPos:Vector2i) -> void:
	
	var dir:Vector2i = GridPos_Utils.Get_RandDirection();
	
	revealerGPos += dir;
	# Spawn Biomes around new position
	World.SpawnBiomes_Around(revealerGPos, 1, 0);
	
	await get_tree().process_frame;
	World.Advance_Time();

func FadeIntoInteraction(gPos:Vector2i) -> void:
	var nextInteraction = Interaction_Master.Get_InteractionType(gPos);
	if nextInteraction == Interaction_Master.Type.Forest:
		if !insideInteraction:
			MultiFader.FadeTo_Trans(playerSpr);
			insideInteraction = true;
		return;
	if insideInteraction:
		MultiFader.FadeTo_Opaque(playerSpr);
		insideInteraction = false;

# Functions [ 3 / 4 ] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

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

# Functions [ 4 / 4 ] ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func SpawnBiomes_ExpandingCircle(count:int) -> void:
	var targs:Array[Vector2i] = GridPos_Utils.GridPositions_Around(currGridPos, 5 + count, true);
	targs = GridPos_Utils.Remove_Occupied(targs);
	
	for gp in targs:
		if gp.distance_to(currGridPos) > 4 + count:
			continue;
		biomeSpawner.SpawnRandomBiomes_Influenced(gp, 1, 2);
	count += 1;
