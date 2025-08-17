extends Camera2D

@export var _mapGenerator:Node2D;
@export var _noiseTex:TextureRect;

#@export var _trees:Node2D;
#@export var _houses:Node2D;
@export var _hide_on_zoom:Node2D;
@export var _show_on_zoom:Node2D;

@export var _cursor:Sprite2D;

const _normSpeed:float = 256;
var _currSpeed:float = _normSpeed;

var _cellSize:float;

var _zoomed:bool;

var _targPos:Vector2;

signal Zoom(on:bool, camTargPos:Vector2);


func _ready() -> void:
	
	_cellSize = _mapGenerator.MapGenerator_Get_CellSize(self.get_path());
	
	await _noiseTex.texture.changed;
	self.position = Vector2.ONE * _cellSize * (sqrt(_noiseTex.get_texture().get_image().get_data().size()) / 2);
	
	_targPos = self.position;


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
	
	# Zoom Out
	if event.is_action_pressed("Zoom") && _zoomed:
		
		_zoomed = false;
		
		_targPos = _cursor.position;
		
		Zoom.emit(_zoomed, _targPos);
		
		#var treeTween:Tween = create_tween();
		#treeTween.set_trans(Tween.TRANS_CUBIC);
		#treeTween.set_ease(Tween.EASE_IN_OUT);
		#treeTween.tween_property(_trees, "modulate:a", 1.0, .5);
		
		#var houseTween:Tween = create_tween();
		#houseTween.set_trans(Tween.TRANS_CUBIC);
		#houseTween.set_ease(Tween.EASE_IN_OUT);
		#houseTween.tween_property(_houses, "modulate:a", 1.0, .5);
		
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
		#await zoomTween.finished;
	
	# Zoom In
	elif event.is_action_pressed("Zoom") && !_zoomed:
		
		_zoomed = true;
		
		Zoom.emit(_zoomed, _targPos);
		
		#var treeTween:Tween = create_tween();
		#treeTween.set_trans(Tween.TRANS_QUAD);
		#treeTween.set_ease(Tween.EASE_IN_OUT);
		#treeTween.tween_property(_trees, "modulate:a", 0, .5);
		
		#var houseTween:Tween = create_tween();
		#houseTween.set_trans(Tween.TRANS_QUAD);
		#houseTween.set_ease(Tween.EASE_IN_OUT);
		#houseTween.tween_property(_houses, "modulate:a", 0, .5);
		
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
		zoomTween.tween_property(self, "zoom", Vector2(3.5, 3.5), 1.25);
		#await zoomTween.finished;
		
	if event.is_action_pressed("Shift"):
		_currSpeed = _normSpeed * 2;
	if event.is_action_released("Shift"):
		_currSpeed = _normSpeed;
