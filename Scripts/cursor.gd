extends Sprite2D

@export var _mapGen:Node2D;

@export var _cam:Camera2D;
#@export var _message:Node2D;
#@export var _messagePanelCont:PanelContainer;

#var World.CellSize:float;

#var _zoomed:bool;

var _moveTimer:float;
var _moveInterval:float = .15;
var _lastDir:Vector2 = Vector2.ZERO;

var _currPos:Vector2;

var _modTween:Tween;

#var _coord:Vector2;


func _init() -> void:
	self.modulate.a = 0;
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN;


func _ready() -> void:
	
	set_process(false);
	
	_cam.Zoom.connect(_Set_Zoomed);
	
	#World.CellSize = _mapGen.MapGenerator_Get_CellSize(self.get_path());
	self.position = floor(self.position / World.CellSize) * World.CellSize;
	
	_currPos = self.position;


func _process(delta: float) -> void:
	
	#_Hold();
	
	#if !Input.is_anything_pressed():
		#return;
		
	if Input.is_action_just_pressed("Enter"):
		
		var pos:Vector2 = World.Coord_OnGrid(self.position);
		var v2_array:Array[Vector2] = World.V2_Array_Around(pos, 1);
		_mapGen.ChangeTerrain(v2_array, 10, self.get_path());
		#_Position_Message();
	
	# Move Immediately on direction key Press
	
	if Input.is_action_just_pressed("Up"):
		self.position.y -= World.CellSize;
		_moveTimer = 0;
	elif Input.is_action_just_pressed("Down"):
		self.position.y += World.CellSize;
		_moveTimer = 0;
	elif Input.is_action_just_pressed("Left"):
		self.position.x -= World.CellSize;
		_moveTimer = 0;
	elif Input.is_action_just_pressed("Right"):
		self.position.x += World.CellSize;
		_moveTimer = 0;
	
	# Repeat Move
	
	# Start Timer
	
	if Input.is_action_pressed("Up"):
		_lastDir = Vector2.UP;
	elif Input.is_action_pressed("Down"):
		_lastDir = Vector2.DOWN;
	elif Input.is_action_pressed("Left"):
		_lastDir = Vector2.LEFT;
	elif Input.is_action_pressed("Right"):
		_lastDir = Vector2.RIGHT;
	
	# Interrupt and Stop Timer
	
	if _DirKey_Is_Released_And_Matches_LastDir(_lastDir):
		_lastDir = Vector2.ZERO;
		_moveTimer = 0;
	
	# Increase Timer
	
	if _lastDir != Vector2.ZERO:
		if _moveTimer < _moveInterval:
			_moveTimer += delta;
		else:
			#_Fade_InOut();
			_moveTimer = 0;
			match _lastDir:
				Vector2.UP:
					self.position.y -= World.CellSize;
					#_Fade_InOut(Vector2.UP);
				Vector2.DOWN:
					self.position.y += World.CellSize;
					#_Fade_InOut(Vector2.DOWN);
				Vector2.LEFT:
					self.position.x -= World.CellSize;
					#_Fade_InOut(Vector2.LEFT);
				Vector2.RIGHT:
					self.position.x += World.CellSize;
					#_Fade_InOut(Vector2.RIGHT);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _DirKey_Is_Released_And_Matches_LastDir(lastDir:Vector2) -> bool:
	if Input.is_action_just_released("Up") && lastDir == Vector2.UP:
		return true;
	elif Input.is_action_just_released("Down") && lastDir == Vector2.DOWN:
		return true;
	elif Input.is_action_just_released("Left") && lastDir == Vector2.LEFT:
		return true;
	elif Input.is_action_just_released("Right") && lastDir == Vector2.RIGHT:
		return true;
	return false;


func _Fade_InOut(dir:Vector2) -> void:
	
	if _modTween:
		_modTween.kill();
	_modTween = create_tween();
	
	_modTween.set_trans(Tween.TRANS_QUART);
	_modTween.set_ease(Tween.EASE_OUT);
	_modTween.set_parallel(true);
	
	self.modulate.a = 0;
	_modTween.tween_property(self, "modulate:a", 1, .5);
	
	_currPos = floor(_currPos / World.CellSize) * World.CellSize + dir * World.CellSize;
	_modTween.tween_property(self, "position", _currPos, .5);


func _Set_Zoomed(on:bool, _camTargPos:Vector2) -> void:
	
	_lastDir = Vector2.ZERO;
	_moveTimer = 0;
	
	if on:
		self.position = floor(_camTargPos / World.CellSize) * World.CellSize;
	
	var alpha:float = on;
	
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(self, "modulate:a", alpha, .5);
	
	set_process(on);


# Back Burner ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


var terrain:Sprite2D;
var marking:Sprite2D;
var detail:Sprite2D;
var detailOffsetY:float;

var holdingTween:Tween;

var mouseStart:Vector2;
var follow:bool;
var origin:Vector2;


#func _Position_Message() -> void:
	#_message.Set_Position_And_Size(self.position, self.get_path());
