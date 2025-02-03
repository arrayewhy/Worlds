extends Node2D;

@onready var biomeSpawner = $"Biome-Spawner";
@onready var buttonMovement = $"Button-Movement";

@export var camMover:Node;

var initGridPos := Vector2i(0,0);
var currGridPos:Vector2i;

signal SpawnAround(pos);

func _ready() -> void:
	currGridPos = initGridPos;
	Spawn_InitialBiomes();

func _process(_delta: float) -> void:
	
	# Check Directional Input
	var inputDir:Vector2i = buttonMovement.Get_InputDirection();
	
	if inputDir == Vector2i(0,0):
		return;
	
	# Update Current Grid Position
	currGridPos += inputDir;
	
	# Spawn Biomes around new position
	SpawnAround.emit(currGridPos);
	
	var targPos = position + Vector2(inputDir) * World.cellSize;
	
	# Move Player
	position = targPos;
	
	# Move Camera
	camMover.StartMove(targPos);

func Spawn_InitialBiomes() -> void:
	biomeSpawner.SpawnBiome(currGridPos, BiomeMaster.Type.Grass);
	biomeSpawner.SpawnRandomBiomes_3x3(Vector2i(0,0));
