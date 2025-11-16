extends Node;

@export var target:Node2D;
@export var startVisible:bool = true;

var initSpeed:float = 2;
var speed:float = 2;

var destAlpha:float;
var dir:int;
var fading:bool;

@export var emitSignal:bool;
signal Complete;

func _ready():
	set_process (false);
	# Auto Initialise Target
	if typeof(target) == 0:
		target = get_parent();
	
	if !startVisible:
		target.modulate.a = 0;
		target.hide();

func _process(delta):
	
	var change:float = (destAlpha - target.modulate.a) * speed * delta;
	
	var newVal = target.modulate.a + change;
	
	var dist = abs(newVal - destAlpha);
	
	var thresh = 0.01;
	
	# Snap to Trans
	
	if dir < 0 and dist < thresh:
		target.modulate.a = 0;
		speed = initSpeed;
		target.hide();
		fading = false;
		set_process (false);
		
		if !emitSignal:
			return;
		Complete.emit();
		
	# Snap to Opaque
	
	elif dir > 0 and dist < thresh:
		target.modulate.a = 1;
		speed = initSpeed;
		fading = false;
		set_process (false);
		
		if !emitSignal:
			return;
		Complete.emit();
	
	target.modulate.a += change;

func FadeToOpaque(spd:float = speed):
	#print ("Fading In");
	destAlpha = 1;
	dir = 1;
	speed = spd;
	Start();
	
func FadeToTrans(spd:float = speed):
	#print ("Fading Out");
	destAlpha = 0;
	dir = -1;
	speed = spd;
	Start();

func Start() -> void:
	target.show();
	fading = true;
	set_process (true);

func Is_Fading() -> bool:
	return fading;
