extends Node;

var targets:Dictionary; # Sprite : Mode, Speed

enum Mode { NULL, FadeTrans, FadeOpaque };

func _process(delta: float) -> void:
	
	# Disable
	if targets == {}:
		set_process(false);

	for t in targets:
		
		if t == null:
			InGameDebugger.Warn("Multi-Fader tried to fade Null Object.");
			RemoveTarget(t);
		
		var targParams:Array = targets[t];
		
		match targParams[0]:
			Mode.NULL:
				InGameDebugger.Warn("Fader mode NOT set.");
			Mode.FadeTrans:
				Fade_Trans(t, targParams[1], delta);
			Mode.FadeOpaque:
				Fade_Opaque(t, targParams[1], delta);

func Fade_Trans(spr:Sprite2D, speed:float, delta:float) -> void:
	
	var nextVal:float = spr.modulate.a - speed * delta;
	
	# Snap to Trans
	if nextVal < 0:
		spr.modulate.a = 0;
		RemoveTarget(spr);
		return;
		
	spr.modulate.a = nextVal;
	
func Fade_Opaque(spr:Sprite2D, speed:float, delta:float) -> void:

	var nextVal:float = spr.modulate.a + speed * delta;
	
	# Snap to Opaque
	if nextVal > 1:
		spr.modulate.a = 1;
		RemoveTarget(spr);
		return;
		
	spr.modulate.a = nextVal;

func Start(spr:Sprite2D, mode:Mode, spd:float) -> void:
	targets[spr] = [mode, spd];
	if !is_processing():
		set_process(true);

# Functions ----------------------------------------------------------------------------------------------------

func FadeTo_Trans(spr:Sprite2D, spd:float = 2, startFromOpaque:bool = false) -> void:
	if startFromOpaque:
		spr.modulate.a = 1;
	Start(spr, Mode.FadeTrans, spd);
	
func FadeTo_Opaque(spr:Sprite2D, spd:float = 2, startFromTrans:bool = false) -> void:
	if startFromTrans:
		spr.modulate.a = 0;
	Start(spr, Mode.FadeOpaque, spd);

func RemoveTarget(spr:Sprite2D) -> void:
	targets.erase(spr);
