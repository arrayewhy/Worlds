extends Camera2D

@export var _trees:Node2D;
@export var _houses:Node2D;
@export var _zoom_objects:Node2D;

var _speed:float = 256;

var _zoomed:bool;

var _targPos:Vector2 = self.position;


func _process(delta: float) -> void:
	if Input.is_action_pressed("Up"):
		_targPos.y -= delta * _speed;
	if Input.is_action_pressed("Down"):
		_targPos.y += delta * _speed;
	if Input.is_action_pressed("Left"):
		_targPos.x -= delta * _speed;
	if Input.is_action_pressed("Right"):
		_targPos.x += delta * _speed;
	
	self.position += (_targPos - self.position) * delta * (_speed / 64);


func _unhandled_key_input(event: InputEvent) -> void:
	
	# Zoom Out
	if event.is_action_pressed("Zoom") && _zoomed:
		
		_zoomed = false;
		
		var treeTween:Tween = create_tween();
		treeTween.set_trans(Tween.TRANS_CUBIC);
		treeTween.set_ease(Tween.EASE_IN_OUT);
		treeTween.tween_property(_trees, "modulate:a", 1.0, .5);
		
		var houseTween:Tween = create_tween();
		houseTween.set_trans(Tween.TRANS_CUBIC);
		houseTween.set_ease(Tween.EASE_IN_OUT);
		houseTween.tween_property(_houses, "modulate:a", 1.0, .5);
		
		var objZoomTween:Tween = create_tween();
		objZoomTween.set_trans(Tween.TRANS_CUBIC);
		objZoomTween.set_ease(Tween.EASE_IN_OUT);
		objZoomTween.tween_property(_zoom_objects, "modulate:a", 0, .5);
		
		var zoomTween:Tween = create_tween();
		zoomTween.set_trans(Tween.TRANS_QUINT);
		zoomTween.set_ease(Tween.EASE_OUT);
		zoomTween.tween_property(self, "zoom", Vector2(1, 1), 1.5);
		#await zoomTween.finished;
	
	# Zoom In
	elif event.is_action_pressed("Zoom") && !_zoomed:
		
		_zoomed = true;
		
		var objZoomTween:Tween = create_tween();
		objZoomTween.set_trans(Tween.TRANS_CUBIC);
		objZoomTween.set_ease(Tween.EASE_IN_OUT);
		objZoomTween.tween_property(_zoom_objects, "modulate:a", 1.0, .5);
		
		var treeTween:Tween = create_tween();
		treeTween.set_trans(Tween.TRANS_QUAD);
		treeTween.set_ease(Tween.EASE_IN_OUT);
		treeTween.tween_property(_trees, "modulate:a", 0, .5);
		
		var houseTween:Tween = create_tween();
		houseTween.set_trans(Tween.TRANS_QUAD);
		houseTween.set_ease(Tween.EASE_IN_OUT);
		houseTween.tween_property(_houses, "modulate:a", 0, .5);
		
		var zoomTween:Tween = create_tween();
		zoomTween.set_trans(Tween.TRANS_CUBIC);
		zoomTween.set_ease(Tween.EASE_IN_OUT);
		zoomTween.tween_property(self, "zoom", Vector2(3, 3), 1.25);
		#await zoomTween.finished;
		
	if event.is_action_pressed("Shift"):
		_speed = 256 * 2;
	if event.is_action_released("Shift"):
		_speed = 256;
