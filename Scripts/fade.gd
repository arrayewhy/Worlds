class_name Fade extends Node

enum Phase { Null, IN, OUT }

var _master:Node2D;

var _idx:int;
var _curr_phase:Phase;
var _curr_dur:float;

var _fadeTween:Tween;

signal Complete(idx:int);


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _init(phase:Phase, targObj:Node2D, targIdx:int = -1, dur:float = .5) -> void:
	
	if targIdx != -1:
		_idx = targIdx;
	
	_curr_phase = phase;
	_master = targObj;
	_curr_dur = dur;
	
	_fadeTween = create_tween();
	
	if _curr_phase == Phase.IN:
		_fadeTween.tween_property(_master, "modulate:a", 1, _curr_dur);
	elif _curr_phase == Phase.OUT:
		_fadeTween.tween_property(_master, "modulate:a", 0, _curr_dur);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Interrupt(newPhase:Phase) -> void:
	
	_curr_phase = newPhase;
	
	_fadeTween.stop();
	_fadeTween = create_tween();
	_fadeTween.set_trans(Tween.TRANS_LINEAR);
	
	if _curr_phase == Phase.IN:
		_fadeTween.tween_property(_master, "modulate:a", 1, _curr_dur);
		
	elif _curr_phase == Phase.OUT:
		_fadeTween.tween_property(_master, "modulate:a", 0, _curr_dur);
	
	_fadeTween.finished.connect(_End);


func Current_Phase() -> Phase:
	return _curr_phase;


func _End() -> void:
	Complete.emit(_idx);
