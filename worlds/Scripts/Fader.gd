extends Node;

@export var target:Node2D;
@export var startVisible:bool = true;
#@export var colorFade:bool;
#var initCol:Color;
var destAlpha:float;
var initSpeed:float = 2;
var speed:float = 2;
var dir:int;
var fading:bool;

@export var emitSignal:bool;
signal Complete;

#@export var hideOnReady:bool = true;

func _ready():
	set_process (false);
	# Auto Initialise Target
	if typeof(target) == 0:
		target = get_parent();
		
	# hide() Target at Start
	
	#if !hideOnReady:
		#return;
	
	if !startVisible:
		
		#if colorFade:
			#initCol = target.modulate;
			#target.modulate = Color(0, 0, 0, 1);
			#return;
		
		target.modulate.a = 0;
		target.hide();

func _process(delta):
	
	var change:float = (destAlpha - target.modulate.a) * speed * delta;
	
	var newVal = target.modulate.a + change;
	
	var dist = abs(newVal - destAlpha);
	
	var thresh = 0.01;
	
	#var nextAlpha = target.modulate.a + speed * dir * delta;
	
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
	
	#if dir < 0 and nextAlpha <= 0:
		#target.modulate.a = 0;
		#speed = initSpeed;
		#target.hide();
		#fading = false;
		#set_process (false);
		#
		#if !emitSignal:
			#return;
		#Complete.emit();
		
	# Snap to Opaque
	
	elif dir > 0 and dist < thresh:
		target.modulate.a = 1;
		speed = initSpeed;
		fading = false;
		set_process (false);
		
		if !emitSignal:
			return;
		Complete.emit();
	
	#elif dir > 0 and nextAlpha >= 1:
		#target.modulate.a = 1;
		#speed = initSpeed;
		#fading = false;
		#set_process (false);
		#
		#if !emitSignal:
			#return;
		#Complete.emit();
		
	#target.modulate.a = nextAlpha;
	
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

#func FadeToInitCol() -> void:
	#pass;
#func FadeToBlack() -> void:
	#pass;

#func FadeTo(spd:float = speed, a:float = 0.5) -> void:
	#if a == 0.5:
		#InGameDebugger.Warn(str("FadeTo() : Target Alpha NOT Set."));
	#destAlpha = a;
	#dir = sign(a - target.modulate.a);
	#speed = spd;
	#Start();

func Start() -> void:
	target.show();
	fading = true;
	set_process (true);

func Is_Fading() -> bool:
	return fading;
