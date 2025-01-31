extends Node;

@export var master:Node2D;

@export var speed:float = 2;
@export var minDist:float = 0.01;
var targPos:Vector2;
var lowestDist:float = 0.0;

func _ready() -> void:
	set_process(false);

func _process(delta: float) -> void:
	
	var dist = master.position.distance_to(targPos);
	
	if dist > lowestDist || dist < minDist:
		master.position = targPos;
		set_process(false);
		#print("Destination Achieved");
		return;
	
	lowestDist = dist;
		
	var change = (targPos - master.position) * speed * delta;
	master.position += change;
	#print(dist);
	
func StartMove(pos) -> void:
	
	var dist = master.position.distance_to(pos);
	
	if dist < minDist:
		return;
		
	targPos = pos;
	lowestDist = dist;
	
	set_process(true);
