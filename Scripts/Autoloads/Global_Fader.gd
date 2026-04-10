extends Node

enum Phase { Null, IN, OUT }

var _active_fades:Dictionary[int, Array]; # Node ID : [ Node, Tween, Phase/Colour ]


func Fade(obj:Node2D, phase:Phase, duration:float, force_start_alpha:bool = true) -> void:
	
	assert(typeof(obj) != TYPE_NIL, str("Fade Target is Null: ", obj.get_path()));
	
	var id:int = obj.get_instance_id();
	
	# If the Node is already fading in the Same Phase, do Nothing.
	# Or else, Stop and Replace the Active Tween.
	if _active_fades.has(id):
		if _active_fades[id][2] == phase:
			return;
		else:
			_active_fades[id][1].kill();
	
	var targ_alpha:float;
	
	match phase:
		
		Phase.IN:
			
			# If the target object is Already Visible,
			# and we wish to Force its Starting Alpha,
			# Zero out its Alpha.
			if obj.modulate.a > 0 && force_start_alpha:
				obj.modulate.a = 0;
			
			if !obj.visible:
				obj.show();
			
			targ_alpha = 1;
			
		Phase.OUT:
			
			# If trying to phase Out an already Invisible object,
			# just set its alpha to Zero.
			if !obj.visible:
				obj.modulate.a = 0;
				return;
			
			# If the target object is Already Partially or fully Faded,
			# and we wish to Force its Starting Alpha,
			# Hard Set its Alpha to 1.
			if obj.modulate.a < 1 && force_start_alpha:
				obj.modulate.a = 1;
			
			targ_alpha = 0;
		_:
			printerr("Fade Phase is Null for: ", obj.get_path());
			targ_alpha = 0;
	
	# Start Fade In Tween
	var tween:Tween = create_tween();
	tween.tween_property(obj, "modulate:a", targ_alpha, duration);
	
	# Record Fade Parameters
	_active_fades.set(id, [obj, tween, phase]);
	
	await tween.finished;
	
	if obj.modulate.a <= 0:
		obj.hide();
	
	_active_fades.erase(id);


func Colour_Fade(obj:Node2D, col:Color, duration:float) -> void:
	
	# TEMPORARY
	# Possible problem when trying to Colour Fade
	# an object that is already Alpha Fading.
	
	var id:int = obj.get_instance_id();
	
	# If the Node is already fading, Stop and Replace the Active Tween.
	if _active_fades.has(id):
		_active_fades[id][1].kill();
	
	# Start Fade In Tween
	var tween:Tween = create_tween();
	
	tween.tween_property(obj, "modulate", col, duration);
	
	# Record Fade Parameters
	_active_fades.set(id, [obj, tween, col]);
	
	await tween.finished;
	
	_active_fades.erase(id);
