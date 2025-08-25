extends Camera2D

@export var _hide_on_zoom:Node2D;
@export var _show_on_zoom:Node2D;

@export var _targObj:Sprite2D;

const _normSpeed:float = 256;
var _currSpeed:float = _normSpeed;

var _zoomed:bool;

var _targPos:Vector2;

var _speedTween:Tween;

signal Zoom(on:bool, camTargPos:Vector2);
# TEMPORARY: For Positioning the Player under the camera on start
signal Cam_Pos_On_MapGenComplete(camPos:Vector2);

@export var _debug:bool;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	# Wait for Initial Map Generation
	World.Initial_MapGen_Complete.connect(_On_Initial_MapGen_Complete);
	# It is Good Practice to Connect to Signals instead of Awaiting Directly,
	# so when we want to Check Connections to this Signal, we can.


func _process(delta: float) -> void:
	
	if !_zoomed:
	
		if Input.is_action_pressed("Up"):
			_targPos.y -= delta * _currSpeed;
		if Input.is_action_pressed("Down"):
			_targPos.y += delta * _currSpeed;
		if Input.is_action_pressed("Left"):
			_targPos.x -= delta * _currSpeed;
		if Input.is_action_pressed("Right"):
			_targPos.x += delta * _currSpeed;

		self.position += (_targPos - self.position) * delta * (_currSpeed / 64);
	
	else:
		
		self.position += (_targObj.position - self.position) * delta * (_currSpeed / 128);


func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Zoom") && _zoomed:
		_Zoom_Out();
	elif event.is_action_pressed("Zoom") && !_zoomed:
		_Zoom_In();
		
	if event.is_action_pressed("Shift"):
		_currSpeed = _normSpeed * 2;
	if event.is_action_released("Shift"):
		_currSpeed = _normSpeed;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Zoom_Out() -> void:
	
		_zoomed = false;
		
		_targPos = _targObj.position;
		
		Zoom.emit(_zoomed, _targPos);
		
		var objTween:Tween = create_tween();
		objTween.set_trans(Tween.TRANS_CUBIC);
		objTween.set_ease(Tween.EASE_IN_OUT);
		objTween.tween_property(_hide_on_zoom, "modulate:a", 1.0, .5);
		
		var objZoomTween:Tween = create_tween();
		objZoomTween.set_trans(Tween.TRANS_CUBIC);
		objZoomTween.set_ease(Tween.EASE_IN_OUT);
		objZoomTween.tween_property(_show_on_zoom, "modulate:a", 0, .5);
		
		var zoomTween:Tween = create_tween();
		zoomTween.set_trans(Tween.TRANS_QUINT);
		zoomTween.set_ease(Tween.EASE_OUT);
		zoomTween.tween_property(self, "zoom", Vector2(1, 1), 1.5);

func _Zoom_In() -> void:
	
		_zoomed = true;
		
		Zoom.emit(_zoomed, _targPos);
		
		var objTween:Tween = create_tween();
		objTween.set_trans(Tween.TRANS_CUBIC);
		objTween.set_ease(Tween.EASE_IN_OUT);
		objTween.tween_property(_hide_on_zoom, "modulate:a", 0, .5);
		
		var objZoomTween:Tween = create_tween();
		objZoomTween.set_trans(Tween.TRANS_CUBIC);
		objZoomTween.set_ease(Tween.EASE_IN_OUT);
		objZoomTween.tween_property(_show_on_zoom, "modulate:a", 1.0, .5);
		
		var zoomTween:Tween = create_tween();
		zoomTween.set_trans(Tween.TRANS_CUBIC);
		zoomTween.set_ease(Tween.EASE_IN_OUT);
		zoomTween.tween_property(self, "zoom", Vector2(3, 3), 2.5);


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Is_Zoomed(callerPath:String) -> bool:
	if _debug: print("\ncamera.gd - Is_Zoomed, called by: ", callerPath);
	return _zoomed;


func Slow_CamSpeed(callerPath:String) -> void:
	if _debug: print("\ncamera.gd - Slow_CamSpeed, called by: ", callerPath);
	if _speedTween && _speedTween.is_running():
		_speedTween.stop();
	_speedTween = create_tween();
	_speedTween.tween_property(self, "_currSpeed", _normSpeed / 32, 1);


func Reset_CamSpeed(callerPath:String) -> void:
	if _debug: print("\ncamera.gd - Reset_CamSpeed, called by: ", callerPath);
	if _speedTween && _speedTween.is_running():
		_speedTween.stop();
	_speedTween = create_tween();
	_speedTween.tween_property(self, "_currSpeed", _normSpeed, 1);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _On_Initial_MapGen_Complete() -> void:
	self.position = Vector2.ONE * World.CellSize * (World.MapWidth_In_Units() / 2);
	_targPos = self.position;
	#_Zoom_In();
	Cam_Pos_On_MapGenComplete.emit(self.position);
