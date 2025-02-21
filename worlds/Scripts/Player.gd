extends Node2D;

@onready var biomeSpawner = $"Biome-Spawner";

@export var camMover:Node;

var initGridPos := Vector2i(0,0);
var currGridPos:Vector2i;

signal SpawnInit(gPos);
signal SpawnAround(currGPos, prevGPos);

func _ready() -> void:
	currGridPos = initGridPos;
	Spawn_InitialBiomes();

func _unhandled_key_input(event: InputEvent) -> void:
	
	var inputDir:Vector2i = Vector2i.ZERO;
	
	# Move and Spawn Repeater
	
	if event.is_action_pressed("One"):
		MovePlayer_And_SpawnBiomes_Repeated(inputDir, 10000);
		return;
	
	# Normal Player Move and Biome Spawn
	
	inputDir = Get_DirectionInput(event);
	if inputDir != Vector2i(0,0):
		MovePlayer_And_SpawnBiomes(inputDir);
		return;
	
func Get_DirectionInput(event:InputEvent) -> Vector2i:
	if event.is_action_pressed("Up"):
		return Vector2i.UP;
	if event.is_action_pressed("Down"):
		return Vector2i.DOWN;
	if event.is_action_pressed("Left"):
		return Vector2i.LEFT;
	if event.is_action_pressed("Right"):
		return Vector2i.RIGHT;
	return Vector2i.ZERO;
		
func Spawn_InitialBiomes() -> void:
	#biomeSpawner.SpawnRandomBiome(currGridPos);
	SpawnInit.emit(currGridPos);
	#biomeSpawner.SpawnRandomBiomes(Vector2i(0,0), 2);

func MovePlayer_And_SpawnBiomes(inputDir:Vector2i) -> void:
	var prevGridPos = currGridPos;
	# Update Current Grid Position
	currGridPos += inputDir;
	# Spawn Biomes around new position
	SpawnAround.emit(currGridPos, prevGridPos);
	var targPos = position + Vector2(inputDir) * World.cellSize;
	# Move Player
	position = targPos;
	# Move Camera
	camMover.StartMove(targPos);

func MovePlayer_And_SpawnBiomes_Repeated(inputDir:Vector2i, repetitions:int = 1000) -> void:
	
	for i in repetitions:
		
		inputDir = Get_RandDirection();
		
		MovePlayer_And_SpawnBiomes(inputDir);
		
	InGameDebugger.Say(World.discoveredBiomes.size());

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
