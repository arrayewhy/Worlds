extends Node2D;

@onready var buttonMovement = $"Button-Movement";

@export var camMover:Node;

func _process(_delta: float) -> void:
	
	# Check Directional Input
	
	var inputDir:Vector2 = buttonMovement.Get_InputDirection();
	
	if inputDir == Vector2(0,0):
		return;
	
	var targPos = position + inputDir * World.cellSize;
	
	# Move Player
	position = targPos;
	
	# Move Camera
	camMover.StartMove(targPos);
