extends Node2D;

@onready var biomeSpawner = $"Biome-Spawner";
@onready var buttonMovement = $"Button-Movement";

@export var camMover:Node;

var initGridPos := Vector2i(0,0);
var currGridPos:Vector2i;

signal SpawnAround(currGPos, prevGPos);

func _ready() -> void:
	currGridPos = initGridPos;
	Spawn_InitialBiomes();

func _unhandled_key_input(event: InputEvent) -> void:
	
	var inputDir:Vector2i = Vector2i.ZERO;
	
	if event.is_action_pressed("One"):
		
		for i in 100:
		
			match randi_range(0, 3):
				0:
					inputDir = Vector2i.UP;
				1:
					inputDir = Vector2i.DOWN;
				2:
					inputDir = Vector2i.LEFT;
				3:
					inputDir = Vector2i.RIGHT;
			
			MovePlayer_And_SpawnBiomes(inputDir);
			
		return;
	
	if Is_DirectionInput(event):
		
		# Check Directional Input
		inputDir = buttonMovement.Get_InputDirection();
		
	if inputDir == Vector2i(0,0):
		return;
	
	MovePlayer_And_SpawnBiomes(inputDir);

func Is_DirectionInput(event:InputEvent) -> bool:
	if event.is_action_pressed("Up") or \
	event.is_action_pressed("Down") or \
	event.is_action_pressed("Left") or \
	event.is_action_pressed("Right"):
		return true;
	return false;
		
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
		
func Spawn_InitialBiomes() -> void:
	biomeSpawner.SpawnRandomBiome(currGridPos);
	biomeSpawner.SpawnRandomBiomes_3x3(Vector2i(0,0));
