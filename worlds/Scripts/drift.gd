class_name Drift extends Node

var _master:Node2D;

var _time:float;
var _moveThresh:float = 2;


func _ready() -> void:
	_master = get_parent();


func _process(delta: float) -> void:
	_time += delta;
	
	if _time < _moveThresh:
		return;
	
	_time = 0;
	_Move_Right();


func _Move_Right() -> void:
	var hideTween:Tween = create_tween();
	hideTween.tween_property(_master, "modulate:a", 0, 1);
	
	await hideTween.finished;
	
	var currX = Tools.Float_OnGrid(_master.position.x);
	_master.position.x = currX + World.CellSize;
	
	var showTween:Tween = create_tween();
	showTween.tween_property(_master, "modulate:a", 1, 1);
