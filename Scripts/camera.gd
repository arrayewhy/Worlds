extends Camera2D

@export var _initialiser:Node;
@export var _hide_on_zoom:Node2D;
@export var _show_on_zoom:Node2D;

const _normSpeed:float = 256;
var _currSpeed:float = _normSpeed;

var _zoomed:bool;

#const _mouse_reset_pos:Vector2 = Vector2(9999, 9999);
var _last_mouse_pos:Vector2;
var _click_holding:bool;
var _zoom_timer:float;
var _dbl_click_timer:float;

var _targObj:AnimatedSprite2D;
var _targPos:Vector2;

var _showHide_tween:Tween;
var _zoom_tween:Tween;
var _speed_tween:Tween;

var _move_dest:Vector2;

signal Zoom(on:bool, camTargPos:Vector2);
# TEMPORARY: For Positioning the Player under the camera on start
#signal Cam_Pos_On_MapGenComplete(camPos:Vector2);

@export var _debug:bool;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	# Wait for Initial Map Generation
	_initialiser.Player_Created.connect(_SIGNAL_Player_Created);
	# It is Good Practice to Connect to Signals instead of Awaiting Directly,
	# so when we want to Check Connections to this Signal, we can.


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Right-Click") && _zoomed:
		_Zoom_Out();
	elif Input.is_action_just_pressed("Right-Click") && !_zoomed:
		_Position_Player(get_global_mouse_position());
		_Zoom_In();
	
	if !_zoomed:
		
		var glob_mouse_pos:Vector2 = get_global_mouse_position();
		
		# Double-click Zoom In
		
		if Input.is_action_just_pressed("Left-Click"):
			
			# Start Double-click Timer
			if _dbl_click_timer == 0:
				_dbl_click_timer += delta;
			
		elif Input.is_action_just_released("Left-Click"):
			
			# Reset Double-click timer on mouse Up
			_dbl_click_timer = 0;
			
			# Disable Map Drag
			_click_holding = false;
		
		# If Double-click timer is Running
		if _dbl_click_timer > 0:
			# 1. If it has NOT Reached the threshold, keep it going
			if _dbl_click_timer < .2:
				_dbl_click_timer += delta;
			# 2. Upon Reaching the threshold, Reset the timer
			else:
				_dbl_click_timer = 0;
				# Do your thing
				if glob_mouse_pos.distance_to(self.global_position) <= 20:
					_Position_Player(self.position);
					_Zoom_In();
				else:
					# Enable Map Drag
					_click_holding = true;
					_last_mouse_pos = glob_mouse_pos;
				
			return;
		
		# Map Drag
		
		if _click_holding:
			if glob_mouse_pos.distance_to(_last_mouse_pos) >= 10:
				_targPos = _targPos + (_last_mouse_pos - glob_mouse_pos);
				_last_mouse_pos = glob_mouse_pos;
	
	if Input.is_action_pressed("Up"):
		_targPos.y -= delta * _currSpeed;
	if Input.is_action_pressed("Down"):
		_targPos.y += delta * _currSpeed;
	if Input.is_action_pressed("Left"):
		_targPos.x -= delta * _currSpeed;
	if Input.is_action_pressed("Right"):
		_targPos.x += delta * _currSpeed;
	
	if !_zoomed || !_targObj:
		_move_dest = self.position + (_targPos - self.position) * delta * (_currSpeed / 64);
		self.position = _move_dest;
	else:
		_move_dest = self.position + (_targObj.position - self.position) * delta * (_currSpeed / 128);
		self.position = _move_dest;

func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Enter"):
		_Position_Player(self.position);
		_Zoom_In();
		return;
	
	if event.is_action_pressed("Zoom") && _zoomed:
		_Zoom_Out();
		return;
	elif event.is_action_pressed("Zoom") && !_zoomed:
		_Zoom_In();
		return;
		
	if event.is_action_pressed("Shift"):
		_currSpeed = _normSpeed * 2;
	if event.is_action_released("Shift"):
		_currSpeed = _normSpeed;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Position_Player(pos:Vector2) -> void:
	_targObj.position = World.Coord_OnGrid(pos);
	World.Set_Player_Coord(World.Coord_OnGrid(_targObj.position), self.get_path());


func _Zoom_Out() -> void:
	
	if !_zoomed:
		return;
	
	_zoomed = false;
	
	if _targObj:
		_targPos = _targObj.position;
	
	Zoom.emit(_zoomed, _targPos);
	
	_Show_Zoomed_OUT_Sprites();
	
	# Zoom Camera Out
	
	if _zoom_tween && _zoom_tween.is_running():
		_zoom_tween.stop();
	
	_zoom_tween = create_tween();
	_zoom_tween.set_parallel(true);
	_zoom_tween.set_trans(Tween.TRANS_QUINT);
	_zoom_tween.set_ease(Tween.EASE_OUT);
	_zoom_tween.tween_property(self, "zoom", Vector2(1, 1), 1.5);
	
	# Show Screen Center Cursor
	
	if self.get_child(0):
		self.get_child(0).show();
		_zoom_tween.tween_property(self.get_child(0), "modulate:a", 1.0, 1.5);
		# Rotate Cursor
		_zoom_tween.tween_property(self.get_child(0), "rotation_degrees", -180, 1.5);

func _Zoom_In() -> void:
	
	if _zoomed:
		return;
	
	_zoomed = true;
	
	Zoom.emit(_zoomed, _targPos);
	
	_Show_Zoomed_IN_Sprites();
	
	# Zoom Camera In
	
	if _zoom_tween && _zoom_tween.is_running():
		_zoom_tween.stop();
	
	_zoom_tween = create_tween();
	_zoom_tween.set_parallel(true);
	_zoom_tween.set_trans(Tween.TRANS_CUBIC);
	_zoom_tween.set_ease(Tween.EASE_IN_OUT);
	_zoom_tween.tween_property(self, "zoom", Vector2(3, 3), 1.5);
	
	# Hide Screen Center Cursor
	if self.get_child(0):
		_zoom_tween.tween_property(self.get_child(0), "rotation_degrees", 180, 1.5);
		_zoom_tween.tween_property(self.get_child(0), "modulate:a", 0, 1.5);
		await _zoom_tween.finished;
		self.get_child(0).hide();
		self.get_child(0).rotation_degrees = 0;


func _Show_Zoomed_IN_Sprites() -> void:
	
	if _showHide_tween && _showHide_tween.is_running():
		_showHide_tween.stop();
	
	_showHide_tween = create_tween();
	_showHide_tween.set_trans(Tween.TRANS_CUBIC);
	_showHide_tween.set_ease(Tween.EASE_IN_OUT);
	_showHide_tween.set_parallel(true);
	_showHide_tween.tween_property(_hide_on_zoom, "modulate:a", 0, .5);
	_showHide_tween.tween_property(_show_on_zoom, "modulate:a", 1.0, .5);
	
	_show_on_zoom.show();
	
	await _showHide_tween.finished;
	
	_hide_on_zoom.hide();


func _Show_Zoomed_OUT_Sprites() -> void:
	
	if _showHide_tween && _showHide_tween.is_running():
		_showHide_tween.stop();
	
	_showHide_tween = create_tween();
	_showHide_tween.set_trans(Tween.TRANS_CUBIC);
	_showHide_tween.set_ease(Tween.EASE_IN_OUT);
	_showHide_tween.set_parallel(true);
	_showHide_tween.tween_property(_hide_on_zoom, "modulate:a", 1.0, .5);
	_showHide_tween.tween_property(_show_on_zoom, "modulate:a", 0, .5);
	
	_hide_on_zoom.show();
	
	await _showHide_tween.finished;
	
	_show_on_zoom.hide();


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Is_Zoomed(callerPath:String) -> bool:
	if _debug: print("\ncamera.gd - Is_Zoomed, called by: ", callerPath);
	return _zoomed;


func Slow_CamSpeed(callerPath:String) -> void:
	if _debug: print("\ncamera.gd - Slow_CamSpeed, called by: ", callerPath);
	
	if _speed_tween && _speed_tween.is_running():
		_speed_tween.stop();
		
	_speed_tween = create_tween();
	_speed_tween.tween_property(self, "_currSpeed", _normSpeed / 32, 1);


func Reset_CamSpeed(callerPath:String) -> void:
	if _debug: print("\ncamera.gd - Reset_CamSpeed, called by: ", callerPath);
	if _speed_tween && _speed_tween.is_running():
		_speed_tween.stop();
	_speed_tween = create_tween();
	_speed_tween.tween_property(self, "_currSpeed", _normSpeed, 1);


#func _Player_Request_Zoom_Out() -> void:
	#if _zoom_tween != null && !_zoom_tween.is_running():
		#_Zoom_Out();


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Player_Created(player:AnimatedSprite2D) -> void:
	
	#player.Player_Request_Zoom_Out.connect(_Player_Request_Zoom_Out);
	
	_targObj = player;
	
	self.position = Vector2.ONE * World.CellSize * (World.MapWidth_In_Units() / 2);
	
	_targPos = self.position;
	
	self.zoom = Vector2(.5, .5);
	
	#Cam_Pos_On_MapGenComplete.emit(self.position);
	
	_initialiser.Player_Created.disconnect(_SIGNAL_Player_Created);
	
	
