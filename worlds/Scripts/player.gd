extends Sprite2D

@onready var _mapGen:Node2D = %map_generator;

@export var _cam:Camera2D;

const _moveSpeed:float = 256;

var _moveDir:Vector2;
var _destination:Vector2;
var _next_idx:int;

var _anim_StaggerTimer:float;

var _moveTween:Tween;
var _hideTween:Tween;

var _revealed_sprites_prev:Array[Sprite2D];


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	_cam.Zoom.connect(_On_Zoomed);
	_cam.Cam_Pos_On_MapGenComplete.connect(_On_Cam_Pos_On_MapGenComplete);
	
	self.position = floor(self.position / World.CellSize) * World.CellSize;
	
	set_process(false);


func _process(delta: float) -> void:
	
	if _anim_StaggerTimer < .0625:
		_anim_StaggerTimer += delta;
		return;
	else:
		_anim_StaggerTimer = 0;
	
	var next_step:Vector2 = self.position + _moveDir * _moveSpeed * delta;
	
	if _moveDir.x > 0 && next_step.x >= _destination.x:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Reveal_And_Hide(_destination);
		return;
	elif _moveDir.x < 0 && next_step.x <= _destination.x:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Reveal_And_Hide(_destination);
		return;
	elif _moveDir.y > 0 && next_step.y >= _destination.y:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Reveal_And_Hide(_destination);
		return;
	elif _moveDir.y < 0 && next_step.y <= _destination.y:
		_Reach_Destination(_destination);
		_Step_On_BuriedTreasure(_next_idx);
		_Reveal_And_Hide(_destination);
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
	
	_destination = self.position + dir * World.CellSize;
	_next_idx = World.Convert_Coord_To_Index(_destination);
	
	var next_terrain:Map_Data.Terrain = _mapGen.Get_Terrain(_next_idx, self.get_path());
	var next_marking:Map_Data.Marking = _mapGen.Get_Marking(_next_idx, self.get_path());
	
	if next_terrain == Map_Data.Terrain.MOUNTAIN:
		return;
	
	_moveDir = (_destination - self.position).normalized();
	
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


func _Reveal_And_Hide(pos:Vector2) -> void:
		
	var surr_coords:Array[Vector2] = World.V2_Array_Around(pos, 1, true);
	
	for coord in surr_coords:
		
		var detail:Sprite2D = _mapGen.Get_DetailSprite(coord, self.get_path());
		
		if detail && !_revealed_sprites_prev.has(detail) && detail.modulate.a <= 0:
			_revealed_sprites_prev.push_back(detail);
			
	if _revealed_sprites_prev.size() > 0:
		
		for i in _revealed_sprites_prev.size():
			
			if _revealed_sprites_prev[i].modulate.a <= 0:
				
				var revealTween:Tween = create_tween();
				revealTween.tween_property(_revealed_sprites_prev[i], "modulate:a", 1, .5);
			
			elif _revealed_sprites_prev[i].position.distance_to(pos) > World.CellSize * 1.5:
				
				var hideTween:Tween = create_tween();
				hideTween.tween_property(_revealed_sprites_prev[i], "modulate:a", 0, .5);
				
				_revealed_sprites_prev.remove_at(i);


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
	
	#set_process(on);
