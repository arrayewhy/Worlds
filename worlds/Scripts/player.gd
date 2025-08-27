extends Sprite2D

@onready var _mapGen:Node2D = %map_generator;

@export var _cam:Camera2D;
@export var _message:Node2D;

const _moveSpeed:float = 128;

var _moveDir:Vector2;
var _destination:Vector2;
var _next_idx:int;

var _anim_StaggerTimer:float;

# Tweens
var _moveTween:Tween;
var _hideTween:Tween;

# Fades
var _reveal_fades:Dictionary;
var _marking_fades:Dictionary;

var _message_target:int = -1;

#var _currCoord:Vector2;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	_cam.Zoom.connect(_On_Zoomed);
	_cam.Cam_Pos_On_MapGenComplete.connect(_On_Cam_Pos_On_MapGenComplete);
	
	self.position = floor(self.position / World.CellSize) * World.CellSize;
	
	#_currCoord = World.Coord_OnGrid(self.position);
	
	set_process(false);


func _process(delta: float) -> void:
	
	#var xMoveVal:float = Input.get_axis("Left", "Right");
	#var yMoveVal:float = Input.get_axis("Up", "Down");
	#
	#var dist:float = sqrt( pow(xMoveVal, 2) + pow(yMoveVal, 2) );
	#
	#var normalized_dir:Vector2 = Vector2(xMoveVal / dist, yMoveVal / dist);
	#
	#if abs(normalized_dir.x) > 0 || abs(normalized_dir.y) > 0:
		#self.position += normalized_dir * 8 * delta;
	#
	#if World.Coord_OnGrid(self.position) == _currCoord:
		#return;
	#else:
		#_currCoord = World.Coord_OnGrid(self.position);
		#_Fade_Reveals(_currCoord);
		#
	#return;
	
	if _anim_StaggerTimer < .0625:
		_anim_StaggerTimer += delta;
		return;
	else:
		_anim_StaggerTimer = 0;
	
	var next_step:Vector2 = self.position + _moveDir * _moveSpeed * delta;
	
	if _moveDir.x > 0 && next_step.x >= _destination.x:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Fade_Reveals(_destination);
		return;
	elif _moveDir.x < 0 && next_step.x <= _destination.x:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Fade_Reveals(_destination);
		return;
	elif _moveDir.y > 0 && next_step.y >= _destination.y:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Fade_Reveals(_destination);
		return;
	elif _moveDir.y < 0 && next_step.y <= _destination.y:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Fade_Reveals(_destination);
		return;
		
	self.position = next_step;


func _unhandled_key_input(event: InputEvent) -> void:
	
	if !_cam.Is_Zoomed(self.get_path()):
		return;
	
	if _moveDir != Vector2.ZERO:
		return;
	
	if event.is_action_pressed("Up"):
		_Move(Vector2.UP);
	elif event.is_action_pressed("Down"):
		_Move(Vector2.DOWN);
	elif event.is_action_pressed("Left"):
		_Move(Vector2.LEFT);
	elif event.is_action_pressed("Right"):
		_Move(Vector2.RIGHT);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Move(dir:Vector2) -> void:
	
	#if _hideTween && _hideTween.is_running():
		#return;
	
	var curr_coord:Vector2 = World.Coord_OnGrid(self.position);
	var curr_idx:int = World.Convert_Coord_To_Index(curr_coord);
	var curr_marking:Map_Data.Marking = _mapGen.Get_Marking(curr_idx, self.get_path());
	
	var next_coord:Vector2 = curr_coord + dir * World.CellSize;
	
	if dir == Vector2.UP:
		if curr_marking == Map_Data.Marking.HOUSE:
			_message.Set_Text("*knock knock*", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, self.get_path());
			_message_target = curr_idx;
			return;
		elif curr_marking == Map_Data.Marking.LIGHTHOUSE:
			_message.Set_Text("I wonder if the guard is asleep.\nHe's usually up all night.", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, self.get_path());
			_message_target = curr_idx;
			return;
	
	_destination = next_coord;
	_next_idx = World.Convert_Coord_To_Index(_destination);
	
	var next_terrain:Map_Data.Terrain = _mapGen.Get_Terrain(_next_idx, self.get_path());
	var next_marking:Map_Data.Marking = _mapGen.Get_Marking(_next_idx, self.get_path());
	
	if next_terrain == Map_Data.Terrain.MOUNTAIN:
		return;
	
	_moveDir = dir;
	
	_anim_StaggerTimer = 0;
	
	set_process(true);
	
	# Enter Forest Fade
	if next_marking == Map_Data.Marking.TREE && next_terrain == Map_Data.Terrain.FOREST:
		
		if _hideTween && _hideTween.is_running():
			_hideTween.stop();
		_hideTween = create_tween();
		_hideTween.tween_property(self, "modulate:a", 0, .5);
		
		_cam.Slow_CamSpeed(self.get_path());
		
		return;
	
	# Exit Forest Fade
	else:
		
		if self.modulate.a >= 1:
			return;
			
		if _hideTween && _hideTween.is_running():
			_hideTween.stop();
		_hideTween = create_tween();
		_hideTween.tween_property(self, "modulate:a", 1, .5);
		
		_cam.Reset_CamSpeed(self.get_path());


func _Reach_Destination(dest:Vector2) -> void:
	self.position = dest;
	_moveDir = Vector2.ZERO;
	set_process(false);


func _Step_On_BuriedTreasure(idx:int) -> void:
	if _mapGen.Get_Buried(idx, self.get_path()) > -1:
		var terrainSpr:Sprite2D = _mapGen.Get_TerrainSprite(_destination, self.get_path());
		terrainSpr.rotation_degrees = randf_range(-4, 4);


func _Fade_Reveals(pos:Vector2) -> void:
		
	var surr_coords:Array[Vector2] = World.V2_Array_Around(pos, 3, true);
	
	for coord in surr_coords:
		
		var idx:int = World.Convert_Coord_To_Index(coord);
		
		var detail_spr:Sprite2D = _mapGen.Get_DetailSprite(coord, self.get_path());
			
		if !detail_spr || detail_spr.modulate.a > 0:
			continue;
		
		if !_reveal_fades.has(idx):
			
			var r_fade:Fade = Fade.new(Fade.Phase.IN, detail_spr, idx);
			detail_spr.add_child(r_fade);
			_reveal_fades.set(idx, r_fade);
			
			var marking_spr:Sprite2D = _mapGen.Get_MarkingSprite(coord, self.get_path());
			
			if marking_spr:
				var m_fade:Fade = Fade.new(Fade.Phase.OUT, marking_spr, idx);
				marking_spr.add_child(m_fade);
				_marking_fades.set(idx, m_fade);
				#marking_spr.modulate.a = 0;
		
		else:
			
			if _reveal_fades.get(idx).Current_Phase() == Fade.Phase.OUT:
				
				if _reveal_fades.get(idx).Complete.is_connected(_On_RevealFade_Complete):
					_reveal_fades.get(idx).Interrupt(Fade.Phase.IN);
					_reveal_fades.get(idx).Complete.disconnect(_On_RevealFade_Complete);
			
			if _marking_fades.get(idx).Current_Phase() == Fade.Phase.IN:
				
				if _marking_fades.get(idx).Complete.is_connected(_On_MarkingFade_Complete):
					_marking_fades.get(idx).Interrupt(Fade.Phase.OUT);
					_marking_fades.get(idx).Complete.disconnect(_On_MarkingFade_Complete);
			
	for f_idx in _reveal_fades.keys():
		
		if World.Convert_Index_To_Coord(f_idx).distance_to(self.position) > World.CellSize * 2.5:
			
			if _message_target == f_idx:
				_message_target = -1;
				_message.Disappear(self.get_path());
			
			if !_reveal_fades.get(f_idx).Complete.is_connected(_On_RevealFade_Complete):
				_reveal_fades.get(f_idx).Interrupt(Fade.Phase.OUT);
				_reveal_fades.get(f_idx).Complete.connect(_On_RevealFade_Complete);
	
	for f_idx in _marking_fades.keys():
		
		if World.Convert_Index_To_Coord(f_idx).distance_to(self.position) > World.CellSize * 2.5:
			
			if !_marking_fades.get(f_idx).Complete.is_connected(_On_MarkingFade_Complete):
				_marking_fades.get(f_idx).Interrupt(Fade.Phase.IN);
				_marking_fades.get(f_idx).Complete.connect(_On_MarkingFade_Complete);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _On_Cam_Pos_On_MapGenComplete(camPos:Vector2) -> void:
	self.position = camPos;


func _On_Zoomed(on:bool, _camTargPos:Vector2) -> void:
	
	#if on:
		#self.position = floor(_camTargPos / World.CellSize) * World.CellSize;
	
	var alpha:float = on;
	
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.set_ease(Tween.EASE_IN_OUT);
	tween.tween_property(self, "modulate:a", alpha, .5);


func _On_RevealFade_Complete(idx:int) -> void:
	_reveal_fades.get(idx).queue_free();
	_reveal_fades.erase(idx);


func _On_MarkingFade_Complete(idx:int) -> void:
	_marking_fades.get(idx).queue_free();
	_marking_fades.erase(idx);
