extends Node2D

var _time:float;

func _process(delta: float) -> void:
	modulate.a = (sin(_time) + 1) / 2;
	#print(modulate.a);
	_time += delta;
