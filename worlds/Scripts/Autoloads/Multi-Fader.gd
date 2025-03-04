extends Node;

var targets:Dictionary; # Sprite : Mode, Speed

enum Mode { NULL, FadeTrans, FadeOpaque, FadeAlpha };

func _process(delta: float) -> void:
	
	# Disable
	if targets == {}:
		set_process(false);

	for t in targets:
		
		var targParams:Array = targets[t];
		
		match targParams[0]:
			Mode.NULL:
				InGameDebugger.Warn("Fader mode NOT set.");
			Mode.FadeTrans:
				Progress_Trans(t, targParams[1], delta);
			Mode.FadeOpaque:
				Progress_Opaque(t, targParams[1], delta);
			Mode.FadeAlpha:
				# Sprite, Speed, Target Alpha, Direction, Delta
				Progress_Alpha(t, targParams[1], targParams[2], targParams[3], delta);

func Progress_Trans(spr:Sprite2D, speed:float, delta:float) -> void:
	
	var nextVal:float = spr.modulate.a - speed * delta;
	
	# Snap to Trans
	if nextVal < 0:
		spr.modulate.a = 0;
		RemoveTarget(spr);
		return;
		
	spr.modulate.a = nextVal;
	
func Progress_Opaque(spr:Sprite2D, speed:float, delta:float) -> void:

	var nextVal:float = spr.modulate.a + speed * delta;
	
	# Snap to Opaque
	if nextVal > 1:
		spr.modulate.a = 1;
		RemoveTarget(spr);
		return;
		
	spr.modulate.a = nextVal;

func Progress_Alpha(spr:Sprite2D, speed:float, targAlpha:float, dir:int, delta:float) -> void:
	
	var nextVal:float = spr.modulate.a + speed * dir * delta;
	
	if dir > 0 and nextVal < targAlpha:
		spr.modulate.a = nextVal;
		return;
	
	if dir < 0 and nextVal > targAlpha:
		spr.modulate.a = nextVal;
		return;
	
	spr.modulate.a = targAlpha;
	RemoveTarget(spr);

func Start(spr:Sprite2D, mode:Mode, spd:float) -> void:
	targets[spr] = [mode, spd];
	if !is_processing():
		set_process(true);
		
func Start_Alpha(spr:Sprite2D, spd:float, targAlpha:float) -> void:
	targets[spr] = [Mode.FadeAlpha, spd, targAlpha, sign(targAlpha - spr.modulate.a)];
	if !is_processing():
		set_process(true);

# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func FadeTo_Trans(spr:Sprite2D, spd:float = 2, startFromOpaque:bool = false) -> void:
	if startFromOpaque:
		spr.modulate.a = 1;
	Start(spr, Mode.FadeTrans, spd);
	
func FadeTo_Opaque(spr:Sprite2D, spd:float = 2, startFromTrans:bool = false) -> void:
	if startFromTrans:
		spr.modulate.a = 0;
	Start(spr, Mode.FadeOpaque, spd);

func FadeTo_Alpha(spr:Sprite2D, targAlpha:float, startAlpha:float, spd:float = 2) -> void:
	spr.modulate.a = startAlpha;
	Start_Alpha(spr, spd, targAlpha);

func RemoveTarget(spr:Sprite2D) -> void:
	targets.erase(spr);
