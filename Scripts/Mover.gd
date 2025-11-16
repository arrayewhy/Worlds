extends Node;

# Components
@export var master:Node2D;
# Variables
@export var speed:float = 2;
@export var minDist:float = 0.01;
var destination:Vector2;
var lowestDist:float = 0.0;
var currPos:Vector2;
# Variables: Frame by Frame
@export var frameByFrame:bool;
@export var initFrameDur:float = 0.1;
var frameTimer:float;

@export var emitSignal:bool;
signal Done;

func _ready() -> void:
	set_process(false);

func _process(delta: float) -> void:
	
	var dist = currPos.distance_to(destination);
	
	if dist > lowestDist || dist < minDist:
		master.position = destination;
		set_process(false);
		if emitSignal:
			Done.emit();
		#print("Destination Achieved");
		return;
	
	lowestDist = dist;
		
	var change = (destination - master.position) * speed * delta;
	
	# We determine the actual intended position before deciding to 
	# assign it to the target or not.
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
	
	# If the target is already close to the destination, skip moving entirely.
	if dist < minDist:
		return;
		
	destination = pos;
	lowestDist = dist;
	
	currPos = master.position;
	
	set_process(true);
