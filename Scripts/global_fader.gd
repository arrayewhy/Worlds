extends Node

enum Phase { Null, IN, OUT }

var _active_fades:Dictionary[int, Array]; # Node ID : [ Node, Tween, Phase ]


func Fade(obj:Node2D, phase:Phase, duration:float) -> void:
	
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
			targ_alpha = 1;
		Phase.OUT:
			targ_alpha = 0;
		_:
			printerr("Fade Phase is Null for: ", obj.get_path());
			targ_alpha = 0;
	
	tween.tween_property(obj, "modulate:a", targ_alpha, duration);
	
	# Record Fade Parameters
	_active_fades.set(id, [obj, tween, phase]);
	
	await tween.finished;
	
	_active_fades.erase(id);
