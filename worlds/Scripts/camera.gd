extends Camera2D

@export var _hide_on_zoom:Node2D;
@export var _show_on_zoom:Node2D;

@export var _cursor:Sprite2D;

const _normSpeed:float = 256;
var _currSpeed:float = _normSpeed;

var _zoomed:bool;

var _targPos:Vector2;

signal Zoom(on:bool, camTargPos:Vector2);


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
		
		self.position += (_cursor.position - self.position) * delta * (_currSpeed / 128);


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
		
		_targPos = _cursor.position;
		
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
		zoomTween.tween_property(self, "zoom", Vector2(3, 3), 1.25);

# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _On_Initial_MapGen_Complete() -> void:
	self.position = Vector2.ONE * World.CellSize * (World.MapWidth() / 2);
	_targPos = self.position;
	#_Zoom_In();
