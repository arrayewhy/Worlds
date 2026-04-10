extends AnimatedSprite2D

@onready var _mapGen:Node2D;

@export var _cam:Camera2D;
@export var _message:Node2D;

const _moveSpeed:float = 42;

var _moving:bool;
var _moveDir:Vector2;
var _destination_coord:Vector2;
var _next_idx:int;

var _anim_StaggerTimer:float;
const _anim_stagger_thresh:float = .06;

var _busy:bool;

var _facing_right:bool = true;

#var _dbl_click_timer:float;

# Tweens
var _hideTween:Tween;

# Fades
#var fade_records_CloseUps:Dictionary;
#var fade_records_Markings:Dictionary;

var _message_curr_idx:int = -1;

#var _currCoord:Vector2;

#signal Player_Request_Zoom_Out;

@export_category("#DEBUG")
@export var _debug:bool;

var _debug_spr_dict:Dictionary[Sprite2D, Color];


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	await get_tree().process_frame;
	
	# Position Player at the Boat
	var boat_coord:Vector2 = _Boat_Coords();
	if boat_coord != Vector2.INF:
		self.position = boat_coord;
		World.Set_Player_Coord(self.position, self.get_path());
	
	_Fade_Details_Around(self.position);
	_Fade_Markings_Around(self.position);


func _process(delta: float) -> void:
	
	if _anim_StaggerTimer < _anim_stagger_thresh:
		_anim_StaggerTimer += delta;
		return;
	else:
		_anim_StaggerTimer = 0;
	#
	#var next_step:Vector2 = self.position + (_destination_coord - self.position) * _moveSpeed * delta;
	var next_step:Vector2 = self.position + _moveDir * _moveSpeed * delta;
	
	#TEMPORARY
	
	# Up
	if _moveDir.y < 0:
		if (_destination_coord.y - next_step.y) < 0:
			self.position = next_step;
		else:
			_Reach_Dest_Or_Continue(next_step);
	# Down
	elif _moveDir.y > 0:
		if (_destination_coord.y - next_step.y) > 0:
			self.position = next_step;
		else:
			_Reach_Dest_Or_Continue(next_step);
	# Left
	elif _moveDir.x < 0:
		if (_destination_coord.x - next_step.x) < 0:
			self.position = next_step;
		else:
			_Reach_Dest_Or_Continue(next_step);
	# Right
	elif _moveDir.x > 0:
		if (_destination_coord.x - next_step.x) > 0:
			self.position = next_step;
		else:
			_Reach_Dest_Or_Continue(next_step);


func _unhandled_key_input(event: InputEvent) -> void:
	
	if _busy:
		return;
	
	if !_cam.Is_Zoomed(self.get_path()):
		return;
	
	if event.is_action("Up"):
		_Move(Vector2.UP);
	elif event.is_action("Down"):
		_Move(Vector2.DOWN);
	elif event.is_action("Left"):
		_Move(Vector2.LEFT);
	elif event.is_action("Right"):
		_Move(Vector2.RIGHT);


# Setup ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Initialise(mapGen:Node2D, cam:Camera2D, msg:Node2D, caller_path:String) -> void:
	_mapGen = mapGen;
	_cam = cam;
	_message = msg;
	if _debug: print("\nplayer.gd - Initialise, called by: ", caller_path);


func _Boat_Coords() -> Vector2:
	
	var m_data:Array[Map_Data.Marking] = _mapGen.Get_Marking_Data(self.get_path());
	
	for m_idx in m_data.size():
		if m_data[m_idx] == Map_Data.Marking.BOAT:
			return Tools.Convert_Index_To_Coord(m_idx);
	
	printerr("_Boat_Coords, NO Boat Found!");
	return Vector2.INF;


# Movement ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Move(dir:Vector2) -> void:
	
	# If we receive Movement input while Moving, do Nothing
	if _moveDir != Vector2.ZERO:
		return;
		#self.position = _destination_coord;
	
	# Flip player Sprite
	
	if dir.x < 0 && _facing_right:
		_facing_right = false;
		self.scale.x *= -1;
	elif dir.x > 0 && !_facing_right:
		_facing_right = true;
		self.scale.x *= -1;
	
	var curr_coord:Vector2 = Tools.Coord_OnGrid(self.position);
	
	var next_coord:Vector2 = curr_coord + dir * World.CellSize;
	
	# Messages
	
	var curr_idx:int = Tools.Convert_Coord_To_Index(curr_coord);
	var curr_marking:Map_Data.Marking = _mapGen.Get_Marking(curr_idx, self.get_path());
	
	if dir == Vector2.UP:
		if curr_marking == Map_Data.Marking.OLD_HOUSE:
			_message.Set_Text("There seems to be no one inside.", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, .5, self.get_path());
			_message_curr_idx = curr_idx;
			_Set_Busy();
			return;
		elif curr_marking == Map_Data.Marking.HOUSE:
			_message.Set_Text("*knock knock*", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, .5, self.get_path());
			_message_curr_idx = curr_idx;
			_Set_Busy();
			return;
		elif curr_marking == Map_Data.Marking.LIGHTHOUSE:
			_message.Set_Text("I wonder if the guard is asleep.\nHe's usually up all night.", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, 3, self.get_path());
			_message_curr_idx = curr_idx;
			_Set_Busy();
			return;
	
	# Movement
	
	_destination_coord = next_coord;
	_next_idx = Tools.Convert_Coord_To_Index(_destination_coord);
	
	var next_marking:Map_Data.Marking = _mapGen.Get_Marking(_next_idx, self.get_path());
	var next_terrain:Map_Data.Terrain = _mapGen.Get_Terrain(_next_idx, self.get_path());
	
	if _debug: print_debug(Map_Data.Terrain.find_key(next_terrain));
	
	# Prevent Movement
	
	if !Tools.Terrain_Is_Land(next_terrain) || next_terrain == Map_Data.Terrain.MOUNTAIN:
		return;
	elif dir == Vector2.DOWN && next_marking == Map_Data.Marking.HOUSE:
		return;
		
	# Allow Movement
	
	World.Set_Player_Coord(Tools.Coord_OnGrid(next_coord), self.get_path());
	
	_moveDir = dir;

	_anim_StaggerTimer = 0;
	
	_moving = true;
	
	# Player Animation
	if dir == Vector2.LEFT || dir == Vector2.RIGHT:
		self.play("Walk_Right");
	
	# Fade Surroundings
	
	_Fade_Markings_Around(_destination_coord);
	_Fade_Details_Around(_destination_coord);
	
	# Forest
	
	if next_marking == Map_Data.Marking.TREE && next_terrain == Map_Data.Terrain.FOREST:
		_Enter_Forest();
	else:
		_Exit_Forest();


func _Reach_Dest_Or_Continue(next_step:Vector2) -> void:
	
	if Input.is_action_pressed("Up") && _moveDir.y < 0:
		self.position = next_step;
		_moveDir = Vector2.ZERO;
		_Move(Vector2.UP);
		return;
	elif Input.is_action_pressed("Down") && _moveDir.y > 0:
		self.position = next_step;
		_moveDir = Vector2.ZERO;
		_Move(Vector2.DOWN);
		return;
	elif Input.is_action_pressed("Left") && _moveDir.x < 0:
		self.position = next_step;
		_moveDir = Vector2.ZERO;
		_Move(Vector2.LEFT);
		return;
	elif Input.is_action_pressed("Right") && _moveDir.x > 0:
		self.position = next_step;
		_moveDir = Vector2.ZERO;
		_Move(Vector2.RIGHT);
		return;
	else:
		self.position = _destination_coord;
		_moveDir = Vector2.ZERO;
		_moving = false;
		#set_process(false);
		self.play("Idle");


#func _Step_On_BuriedTreasure(idx:int) -> void:
	#if _mapGen.Get_Buried(idx, self.get_path()) > -1:
		#var terrainSpr:Sprite2D = _mapGen.Get_Spr_Terrain(_destination_coord, self.get_path());
		#terrainSpr.rotation_degrees = randf_range(-4, 4);


# Functions: Forest Fade ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Fade_Markings_Around(coord:Vector2) -> void:
	
	if _debug:
		for debug_spr in _debug_spr_dict.keys():
			debug_spr.modulate = _debug_spr_dict[debug_spr];
		_debug_spr_dict.clear();
	
	# Get Surrounding Grid Coordinates
	# Get Markings at those coordinates
	# If they are close enough, Fade them in
	for v2 in Tools.V2_Array_Around(coord, 10):
		
		var spr:Sprite2D;
		var phase:Fader.Phase = Fader.Phase.IN;
		var fade_dur:float = 1;
		
		# Nearby Coordinates
		if v2.distance_to(coord) < World.CellSize * 3:
			
			if _debug:
				var debug_spr:Sprite2D = _mapGen.Get_Spr_Terrain(v2, self.get_path());
				_debug_spr_dict.set(debug_spr, debug_spr.modulate);
				debug_spr.modulate.a /= 4;
			
			# If there is a Detail Sprite Nearby,
			# but it is Visible, do Nothing.
			var detail_spr:Sprite2D = _mapGen.Get_Spr_Detail(v2, self.get_path());
			if detail_spr != null && detail_spr.visible:
				continue;
			
			spr = _mapGen.Get_Spr_Marking(v2, self.get_path());
			
			if spr == null || spr.visible:
				continue;
		
		# Markings outside of Direct Vicinity
		elif v2.distance_to(coord) > World.CellSize * 4 && v2.distance_to(coord) < World.CellSize * 6:
			
			if _debug:
				var debug_spr:Sprite2D = _mapGen.Get_Spr_Terrain(v2, self.get_path());
				_debug_spr_dict.set(debug_spr, debug_spr.modulate);
				debug_spr.modulate.a = 0;
			
			var marking:Map_Data.Marking = _mapGen.Get_Marking(Tools.Convert_Coord_To_Index(v2), self.get_path());
			
			if marking == Map_Data.Marking.MINI_MOUNT || \
			marking == Map_Data.Marking.PEAK || \
			marking == Map_Data.Marking.LIGHTHOUSE || \
			marking == Map_Data.Marking.FOREST_FIRE:
				continue;
			
			spr = _mapGen.Get_Spr_Marking(v2, self.get_path());
			phase = Fader.Phase.OUT;
			fade_dur = 4;
			
			if spr == null || !spr.visible:
				continue;
				
		# Distant Coordinates
		elif v2.distance_to(coord) > World.CellSize * 4 && v2.distance_to(coord) < World.CellSize * 11:
			
			if _debug:
				var debug_spr:Sprite2D = _mapGen.Get_Spr_Terrain(v2, self.get_path());
				_debug_spr_dict.set(debug_spr, debug_spr.modulate);
				debug_spr.modulate.a /= 4;
			
			var marking:Map_Data.Marking = _mapGen.Get_Marking(Tools.Convert_Coord_To_Index(v2), self.get_path());
			
			fade_dur = 8;
			
			if marking == Map_Data.Marking.MINI_MOUNT || \
			marking == Map_Data.Marking.PEAK:
				spr = _mapGen.Get_Spr_Marking(v2, self.get_path());
			elif marking == Map_Data.Marking.LIGHTHOUSE:
				spr = _mapGen.Get_Spr_Marking(v2, self.get_path());
				fade_dur = 4;
			elif marking == Map_Data.Marking.FOREST_FIRE:
				spr = _mapGen.Get_Spr_Marking(v2, self.get_path());
				fade_dur = 20;
			
			if spr == null || spr.visible:
				continue;
		
		if spr == null:
			continue;
		
		# TEMPORARY
		# Fading does NOT account for Unique Alphas
		
		# Start Fade
		Fader.Fade(spr, phase, fade_dur);


func _Fade_Details_Around(coord:Vector2) -> void:
	# Get Surrounding Grid Coordinates
	# Get Terrain Sprites at those coordinates
	# If they are close enough, Fade them in
	for v2 in Tools.V2_Array_Around(coord, 2):
		
		#if v2.distance_to(coord) > World.CellSize * 32:
			#continue;
		
		var spr:Sprite2D;
		var fade_dur:float = 1;
		
		# Inside Visibility Range
		if v2.distance_to(coord) < World.CellSize * 2:
			
			spr = _mapGen.Get_Spr_Detail(v2, self.get_path());
		
			if spr == null || spr.visible:
				continue;
				
			# TEMPORARY
			# Fading does NOT account for Unique Alphas
				
			# Fade Detail In
			Fader.Fade(spr, Fader.Phase.IN, fade_dur);
			# Fade Marking Out
			spr = _mapGen.Get_Spr_Marking(v2, self.get_path());
			Fader.Fade(spr, Fader.Phase.OUT, fade_dur);
		
		# Outside Visibility Range
		else:
			
			# If a Detail is Far away and is Visible,
			# 1. Fade it Out
			# 2. Fade the Marking on its cell back In.
			
			var outside_detail:Sprite2D = _mapGen.Get_Spr_Detail(v2, self.get_path());
			if outside_detail && outside_detail.visible:
				
				Fader.Fade(outside_detail, Fader.Phase.OUT, fade_dur);
				
				# Fade Marking on the Detail cell back In
				
				var outside_marking:Sprite2D = _mapGen.Get_Spr_Marking(v2, self.get_path());
				if outside_marking:
					
					# TEMPORARY
					# Fading does NOT account for Unique Alphas
					
					Fader.Fade(outside_marking, Fader.Phase.IN, fade_dur);


#func _Fade_CloseUps_And_Markings(pos:Vector2) -> void:
	#
	#var surr_coords:Array[Vector2] = Tools.V2_Array_Around(pos, 1, true);
	#
	#var new_records:Array[int];
	#
	#for coord in surr_coords:
		#
		#var idx:int = Tools.Convert_Coord_To_Index(coord);
		#
		#var closeUp_spr:Sprite2D = _mapGen.Get_Spr_Detail(coord, self.get_path());
		#
		## If the sprite at this coordinate Starts Visible, it probably is NOT a Close-Up Sprite
		#if !closeUp_spr || closeUp_spr.modulate.a > 0:
			#continue;
		#
		## If the Current Close-Up sprite's Index is NOT Recorded and Faded
		##if !fade_records_CloseUps.has(idx):
		## Record its Index and Fade it
		#closeUp_spr.add_child(_Create_And_Record_Fade(Fade.Phase.IN, idx, closeUp_spr, fade_records_CloseUps));
		## Do the Same for the Marking on the same Index
		#var marking_spr:Sprite2D = _mapGen.Get_Spr_Marking(coord, self.get_path());
		#if marking_spr:
			#marking_spr.add_child(_Create_And_Record_Fade(Fade.Phase.OUT, idx, marking_spr, fade_records_Markings));
		#
		#new_records.push_back(idx);
	#
	## Fade sprites when Out of Range
	#
	## Close-ups
	#for f_idx in fade_records_CloseUps.keys():
		#
		#if new_records.has(f_idx):
			#continue;
		#
		#if Tools.Convert_Index_To_Coord(f_idx).distance_to(_destination_coord) > World.CellSize * 1.5:
				#
			## Fade Close-up sprite Out
			#fade_records_CloseUps.get(f_idx).Interrupt(Fade.Phase.OUT);
			## Connect to Signal to Remove this Fade from the Records
			#if !fade_records_CloseUps.get(f_idx).Complete.is_connected(_RemoveFade_CloseUp):
				#fade_records_CloseUps.get(f_idx).Complete.connect(_RemoveFade_CloseUp);
	#
	## Markings
	#for f_idx in fade_records_Markings.keys():
		#if new_records.has(f_idx):
			#continue;
		#if Tools.Convert_Index_To_Coord(f_idx).distance_to(_destination_coord) > World.CellSize * 1.5:
			## Fade Marking sprite In
			#fade_records_Markings.get(f_idx).Interrupt(Fade.Phase.IN);
			## Connect to Signal to Remove this Fade from the Records
			#if !fade_records_Markings.get(f_idx).Complete.is_connected(_RemoveFade_Marking):
				#fade_records_Markings.get(f_idx).Complete.connect(_RemoveFade_Marking);


#func _Create_And_Record_Fade(phase:Fade.Phase, idx:int, spr:Sprite2D, records:Dictionary) -> Fade:
	#var fade:Fade = Fade.new(phase, spr, idx);
	#records.set(idx, fade);
	#return fade;


func _Enter_Forest() -> void:
	
	# TEMPORARY: Rotate TREE sprite
	_mapGen.Get_Spr_Marking(_destination_coord, self.get_path()).rotation_degrees = randf_range(-4, 4);
	
	if self.modulate.a <= 0:
		return;
	Fader.Fade(self, Fader.Phase.OUT, .5);
	
	#if _hideTween && _hideTween.is_running():
		#_hideTween.stop();
	#_hideTween = create_tween();
	#_hideTween.tween_property(self, "modulate:a", 0, .5);
	#
	#await _hideTween.finished;
	#self.hide();
	
	#_cam.Slow_CamSpeed(self.get_path());

func _Exit_Forest() -> void:
	
	if self.modulate.a > 0:
		return;
	Fader.Fade(self, Fader.Phase.IN, .5);
		#
	#self.show();
		#
	#if _hideTween && _hideTween.is_running():
		#_hideTween.stop();
	#_hideTween = create_tween();
	#_hideTween.tween_property(self, "modulate:a", 1, .5);


func _Set_Busy() -> void:
	_busy = true;
	if !_message.Message_Closed.is_connected(_SIGNAL_Set_Not_Busy):
		_message.Message_Closed.connect(_SIGNAL_Set_Not_Busy);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Set_Not_Busy() -> void:
	_busy = false;
	if _message.Message_Closed.is_connected(_SIGNAL_Set_Not_Busy):
		_message.Message_Closed.disconnect(_SIGNAL_Set_Not_Busy);


#func _RemoveFade_CloseUp(idx:int) -> void:
	#fade_records_CloseUps.get(idx).queue_free();
	#fade_records_CloseUps.erase(idx);


#func _RemoveFade_Marking(idx:int) -> void:
	#fade_records_Markings.get(idx).queue_free();
	#fade_records_Markings.erase(idx);
