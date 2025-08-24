class_name Drift extends Node

var _master:Node2D;

#REFACTOR
#@onready var _mapGen:Node2D;
@onready var _mapGen:Node2D = get_parent().get_parent().get_parent();

const _moveThresh:float = 3;

var _time:float;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	_master = get_parent();
	_Move_Right();


func _process(delta: float) -> void:
	
	_time += delta;
	if _time < _moveThresh:
		return;
	
	_time = 0;
	_Move_Right();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Move_Right() -> void:
	
	var hideTween:Tween = create_tween();
	hideTween.tween_property(_master, "modulate:a", 0, _moveThresh / 2);
	
	await hideTween.finished;
	
	var currX = World.Float_OnGrid(_master.position.x);
	_master.position.x = currX + World.CellSize;
	
	if _mapGen.Is_Land(_master.position, self.get_path()):
		set_process(false);
		_master.modulate = Color(0, 0, 0, 0);
	
	var showTween:Tween = create_tween();
	showTween.tween_property(_master, "modulate:a", 1, _moveThresh / 2);
