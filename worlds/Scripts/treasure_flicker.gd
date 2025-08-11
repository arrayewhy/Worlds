class_name Treasure_Flicker extends Node

@onready var _treasure:Sprite2D = get_parent();

var _speed:float = 4;
var _cellSize:float;

var _time:float;
var _updateTime:float;


func _init() -> void:
	_speed *= randf_range(.5, 1);
	_time = randf_range(0, 1);


func _process(delta: float) -> void:
	_time += delta * _speed;
	
	if _time < _updateTime:
		return;
	
	_updateTime = _time + 0.2;
	
	var val:float = ((sin(_time) + 1) / 2) + .125;
	_treasure.modulate.a = val;
	_treasure.scale = Vector2(val, val) / _cellSize;


func Set_CellSize(size:float) -> void:
	_cellSize = size;
