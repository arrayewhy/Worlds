extends Node;

@export var master:Node2D;

@export var speed:float = 2;
@export var minDist:float = 0.01;

@export var frameByFrame:bool;
var initFrameDur:float = 0.1;
var frameTimer:float;

var targPos:Vector2;
var lowestDist:float = 0.0;
var currPos:Vector2;

@export var emitSignal:bool;
signal Done;

func _ready() -> void:
	set_process(false);

func _process(delta: float) -> void:
	
	var dist = currPos.distance_to(targPos);
	
	if dist > lowestDist || dist < minDist:
		master.position = targPos;
		set_process(false);
		if emitSignal:
			Done.emit();
		#print("Destination Achieved");
		return;
	
	lowestDist = dist;
		
	var change = (targPos - master.position) * speed * delta;
	
	currPos += change;
	
	if frameByFrame:
		if frameTimer > 0:
			frameTimer -= delta;
			return;
		frameTimer = initFrameDur;
	
	master.position = currPos;
	#print(dist);
	
func StartMove(pos) -> void:
	
	var dist = master.position.distance_to(pos);
	
	if dist < minDist:
		return;
		
	targPos = pos;
	lowestDist = dist;
	
	currPos = master.position;
	
	set_process(true);
