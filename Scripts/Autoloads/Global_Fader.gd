extends Node

enum Phase { Null, IN, OUT }

var _active_fades:Dictionary[int, Array]; # Node ID : [ Node, Tween, Phase/Colour ]


func Fade(obj:Node2D, phase:Phase, duration:float, end_alpha:float = INF) -> void:
	
	var id:int = obj.get_instance_id();
	
	# If the Node is already fading in the Same Phase, do Nothing.
	# Or else, Stop and Replace the Active Tween.
	if _active_fades.has(id):
		if _active_fades[id][2] == phase:
			return;
		else:
			_active_fades[id][1].kill();
	
	# Start Fade In Tween
	var tween:Tween = create_tween();
	
	var targ_alpha:float;
	
	match phase:
		Phase.IN:
			if end_alpha == INF:
				targ_alpha = 1;
			else:
				targ_alpha = end_alpha;
		Phase.OUT:
			if end_alpha == INF:
				targ_alpha = 0;
			else:
				targ_alpha = end_alpha;
		_:
			printerr("Fade Phase is Null for: ", obj.get_path());
			targ_alpha = 0;
	
	tween.tween_property(obj, "modulate:a", targ_alpha, duration);
	
	# Record Fade Parameters
	_active_fades.set(id, [obj, tween, phase]);
	
	await tween.finished;
	
	_active_fades.erase(id);


func Colour_Fade(obj:Node2D, col:Color, duration:float) -> void:
	
	var id:int = obj.get_instance_id();
	
	# If the Node is already fading in the Same Phase, do Nothing.
	# Or else, Stop and Replace the Active Tween.
	if _active_fades.has(id):
		if _active_fades[id][2] == col:
			return;
		else:
			_active_fades[id][1].kill();
	
	# Start Fade In Tween
	var tween:Tween = create_tween();
	
	tween.tween_property(obj, "modulate", col, duration);
	
	# Record Fade Parameters
	_active_fades.set(id, [obj, tween, col]);
	
	await tween.finished;
	
	_active_fades.erase(id);
