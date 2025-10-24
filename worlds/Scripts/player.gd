extends Sprite2D

@onready var _mapGen:Node2D;

@export var _cam:Camera2D;
@export var _message:Node2D;

const _moveSpeed:float = 128;

var _moveDir:Vector2;
var _destination:Vector2;
var _next_idx:int;

var _anim_StaggerTimer:float;
const _anim_stagger_thresh:float = .07;

# Tweens
var _moveTween:Tween;
var _hideTween:Tween;

# Fades
var fade_records_CloseUps:Dictionary;
var fade_records_Markings:Dictionary;

var _message_curr_idx:int = -1;

#var _currCoord:Vector2;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
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
		#_Fade_CloseUps_And_Markings(_currCoord);
		#
	#return;
	
	if _anim_StaggerTimer < _anim_stagger_thresh:
		_anim_StaggerTimer += delta;
		return;
	else:
		_anim_StaggerTimer = 0;
	#
	var next_step:Vector2 = self.position + (_destination - self.position) * 32 * delta;
	
	if self.position.distance_to(next_step) < .125:
		_Reach_Destination();
		_Step_On_BuriedTreasure(_next_idx);
		#_Fade_CloseUps_And_Markings(_destination);
		return;
	else:
		self.position = next_step;
	
	#var next_step:Vector2 = self.position + _moveDir * _moveSpeed * delta;
	#
	#if _moveDir.x > 0 && next_step.x >= _destination.x:
		#_Reach_Destination();
		#_Step_On_BuriedTreasure(_next_idx);
		#_Fade_CloseUps_And_Markings(_destination);
		#return;
	#elif _moveDir.x < 0 && next_step.x <= _destination.x:
		#_Reach_Destination();
		#_Step_On_BuriedTreasure(_next_idx);
		#_Fade_CloseUps_And_Markings(_destination);
		#return;
	#elif _moveDir.y > 0 && next_step.y >= _destination.y:
		#_Reach_Destination();
		#_Step_On_BuriedTreasure(_next_idx);
		#_Fade_CloseUps_And_Markings(_destination);
		#return;
	#elif _moveDir.y < 0 && next_step.y <= _destination.y:
		#_Reach_Destination();
		#_Step_On_BuriedTreasure(_next_idx);
		#_Fade_CloseUps_And_Markings(_destination);
		#return;
		#
	#self.position = next_step;


func _unhandled_key_input(event: InputEvent) -> void:
	
	if !_cam.Is_Zoomed(self.get_path()):
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
	
	# If we receive Movement input while Moving, Snap the player to the Destination
	if _moveDir != Vector2.ZERO && self.position.distance_to(_destination) > 1:
		return;
		#self.position = _destination;
	
	var curr_coord:Vector2 = World.Coord_OnGrid(self.position);
	var curr_idx:int = World.Convert_Coord_To_Index(curr_coord);
	var curr_marking:Map_Data.Marking = _mapGen.Get_Marking(curr_idx, self.get_path());
	
	var next_coord:Vector2 = curr_coord + dir * World.CellSize;
	
	# Messages
	if dir == Vector2.UP:
		if curr_marking == Map_Data.Marking.HOUSE:
			_message.Set_Text("*knock knock*", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, .5, self.get_path());
			_message_curr_idx = curr_idx;
			return;
		elif curr_marking == Map_Data.Marking.LIGHTHOUSE:
			_message.Set_Text("I wonder if the guard is asleep.\nHe's usually up all night.", self.get_path());
			_message.Set_Position_And_Size(next_coord + dir * World.CellSize, 3, self.get_path());
			_message_curr_idx = curr_idx;
			return;
	
	_destination = next_coord;
	_next_idx = World.Convert_Coord_To_Index(_destination);
	
	var next_terrain:Map_Data.Terrain = _mapGen.Get_Terrain(_next_idx, self.get_path());
	var next_marking:Map_Data.Marking = _mapGen.Get_Marking(_next_idx, self.get_path());
	
	if !World.Terrain_Is_Land(next_terrain) || next_terrain == Map_Data.Terrain.MOUNTAIN:
		return;
	
	_moveDir = dir;
	
	_anim_StaggerTimer = 0;
	
	set_process(true);
	
	_Fade_CloseUps_And_Markings(_destination);
	
	# Forest
	#if next_marking == Map_Data.Marking.TREE && next_terrain == Map_Data.Terrain.FOREST:
		#_Enter_Forest();
	#else:
		#_Exit_Forest();


func _Reach_Destination() -> void:
	self.position = _destination;
	_moveDir = Vector2.ZERO;
	set_process(false);


func _Step_On_BuriedTreasure(idx:int) -> void:
	if _mapGen.Get_Buried(idx, self.get_path()) > -1:
		var terrainSpr:Sprite2D = _mapGen.Get_TerrainSprite(_destination, self.get_path());
		terrainSpr.rotation_degrees = randf_range(-4, 4);


func Initialise(mapGen:Node2D, cam:Camera2D, msg:Node2D) -> void:
	_mapGen = mapGen;
	_cam = cam;
	_message = msg;


# Functions: Forest Fade ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Fade_CloseUps_And_Markings(pos:Vector2) -> void:
	
	var surr_coords:Array[Vector2] = World.V2_Array_Around(pos, 1, true);
	
	var new_records:Array[int];
	
	for coord in surr_coords:
		
		var idx:int = World.Convert_Coord_To_Index(coord);
		
		var closeUp_spr:Sprite2D = _mapGen.Get_DetailSprite(coord, self.get_path());
		
		# If the sprite at this coordinate Starts Visible, it probably is NOT a Close-Up Sprite
		if !closeUp_spr || closeUp_spr.modulate.a > 0:
			continue;
		
		# If the Current Close-Up sprite's Index is NOT Recorded and Faded
		#if !fade_records_CloseUps.has(idx):
		# Record its Index and Fade it
		closeUp_spr.add_child(_Create_And_Record_Fade(Fade.Phase.IN, idx, closeUp_spr, fade_records_CloseUps));
		# Do the Same for the Marking on the same Index
		var marking_spr:Sprite2D = _mapGen.Get_MarkingSprite(coord, self.get_path());
		if marking_spr:
			marking_spr.add_child(_Create_And_Record_Fade(Fade.Phase.OUT, idx, marking_spr, fade_records_Markings));
		
		new_records.push_back(idx);
		
		#else:
			#
			## If the Current Close-up sprite is Fading Out,
			## we Interrupt it and Fade it back In.
			## We do the same for the Marking Sprite.
			#
			## Close-ups
			#if fade_records_CloseUps.get(idx).Current_Phase() == Fade.Phase.OUT:
				#
				## Fade Close-up sprite In
				#fade_records_CloseUps.get(idx).Interrupt(Fade.Phase.IN);
				## Cancel Fade Removal
				#if fade_records_CloseUps.get(idx).Complete.is_connected(_RemoveFade_CloseUp):
					#fade_records_CloseUps.get(idx).Complete.disconnect(_RemoveFade_CloseUp);
			#
			## Markings
			#if fade_records_Markings.get(idx).Current_Phase() == Fade.Phase.IN:
				## Fade Marking sprite Out
				#fade_records_Markings.get(idx).Interrupt(Fade.Phase.OUT);
				## Cancel Fade Removal
				#if fade_records_Markings.get(idx).Complete.is_connected(_RemoveFade_Marking):
					#fade_records_Markings.get(idx).Complete.disconnect(_RemoveFade_Marking);
	
	# Fade sprites when Out of Range
	
	# Close-ups
	for f_idx in fade_records_CloseUps.keys():
		
		if new_records.has(f_idx):
			continue;
		
		if World.Convert_Index_To_Coord(f_idx).distance_to(_destination) > World.CellSize * 1.5:
			
			# Fade Message Out
			#if _message_curr_idx == f_idx:
				#_message_curr_idx = -1;
				#_message.Disappear(self.get_path());
				
			# Fade Close-up sprite Out
			fade_records_CloseUps.get(f_idx).Interrupt(Fade.Phase.OUT);
			# Connect to Signal to Remove this Fade from the Records
			if !fade_records_CloseUps.get(f_idx).Complete.is_connected(_RemoveFade_CloseUp):
				fade_records_CloseUps.get(f_idx).Complete.connect(_RemoveFade_CloseUp);
	
	# Markings
	for f_idx in fade_records_Markings.keys():
		if new_records.has(f_idx):
			continue;
		if World.Convert_Index_To_Coord(f_idx).distance_to(_destination) > World.CellSize * 1.5:
			# Fade Marking sprite In
			fade_records_Markings.get(f_idx).Interrupt(Fade.Phase.IN);
			# Connect to Signal to Remove this Fade from the Records
			if !fade_records_Markings.get(f_idx).Complete.is_connected(_RemoveFade_Marking):
				fade_records_Markings.get(f_idx).Complete.connect(_RemoveFade_Marking);


func _Create_And_Record_Fade(phase:Fade.Phase, idx:int, spr:Sprite2D, records:Dictionary) -> Fade:
	var fade:Fade = Fade.new(phase, spr, idx);
	records.set(idx, fade);
	return fade;


#func _Enter_Forest() -> void:
	# TEMPORARY: Rotate TREE sprite
	#_mapGen.Get_MarkingSprite(_destination, self.get_path()).rotation_degrees = randf_range(-4, 4);
	
	#if _hideTween && _hideTween.is_running():
		#_hideTween.stop();
	#_hideTween = create_tween();
	#_hideTween.tween_property(self, "modulate:a", 0, .5);
	
	#_cam.Slow_CamSpeed(self.get_path());


#func _Exit_Forest() -> void:
	
	#if self.modulate.a >= 1:
		#return;
		
	#if _hideTween && _hideTween.is_running():
		#_hideTween.stop();
	#_hideTween = create_tween();
	#_hideTween.tween_property(self, "modulate:a", 1, .5);
	
	#_cam.Reset_CamSpeed(self.get_path());


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _RemoveFade_CloseUp(idx:int) -> void:
	fade_records_CloseUps.get(idx).queue_free();
	fade_records_CloseUps.erase(idx);


func _RemoveFade_Marking(idx:int) -> void:
	fade_records_Markings.get(idx).queue_free();
	fade_records_Markings.erase(idx);
