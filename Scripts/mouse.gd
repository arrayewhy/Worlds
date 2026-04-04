extends Node2D

@onready var _mapGen:Node = $"../map_generator";

#var _terrain_lifters:Dictionary;

var _last_mouse_pos:Vector2;

var _hover_timer:float;
var _curr_hover_coord:Vector2 = Vector2.INF;

var _skip_fade:bool;

#TEMPORARY
# Why do we need this signal?
# Why not just have scripts check Input as usual?
signal Left_Click(mouse_coord:Vector2);


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _process(delta: float) -> void:
	
	var mouse_pos:Vector2 = get_global_mouse_position();
	
	if Input.is_action_just_pressed("Left-Click"):
		
		Left_Click.emit(get_global_mouse_position());
		
		# Play Ship Horn Sound on Click
		var mouse_grid_pos:Vector2 = World.Coord_OnGrid(get_global_mouse_position());
		var idx:int = World.Convert_Coord_To_Index(mouse_grid_pos);
		if _mapGen.Get_Marking(idx, self.get_path()) == Map_Data.Marking.BOAT:
			SoundMaster.Ship_Horn();
			
	if _curr_hover_coord == Vector2.INF:
		if mouse_pos.distance_to(_last_mouse_pos) < 2:
			_hover_timer += delta;
		else:
			_hover_timer = 0;
	else:
		
		if mouse_pos.distance_to(_curr_hover_coord) > World.CellSize * .75:

			# Reset Detail or Secret
			_Reset_Reveal(_curr_hover_coord);
			
			_curr_hover_coord = Vector2.INF;
	
	# Reveal Detail or Secret
	
	if _hover_timer >= .2:
		
		_hover_timer = 0;
		
		_curr_hover_coord = World.Coord_OnGrid(mouse_pos);
		
		_Reveal(_curr_hover_coord);
	
	_last_mouse_pos = mouse_pos;


func _Reveal(coord:Vector2) -> void:
	
	var secret_spr:Sprite2D = _mapGen.Get_Spr_Secret(coord, self.get_path());
	
	if secret_spr:
		
		# Secret
		Fader.Fade(secret_spr, Fader.Phase.IN, .5);
		
		# TEMPORARY: Mountain Dragon Growl
		var secret_type:Map_Data.Secrets = _mapGen.Get_Secret(World.Convert_Coord_To_Index(coord), self.get_path());
		if secret_type == Map_Data.Secrets.DRAGON:
			SoundMaster.Dragon_Growl();
		
		# Detail
		var detail_spr:Sprite2D = _mapGen.Get_Spr_Detail(coord, self.get_path());
		if detail_spr:
			Fader.Fade(detail_spr, Fader.Phase.OUT, .5);
		# Terrain
			var terrain_spr = _mapGen.Get_TerrainSprite(coord, self.get_path());
			Fader.Colour_Fade(terrain_spr, Color.BLACK, .5);
	else:
		var detail_spr:Sprite2D = _mapGen.Get_Spr_Detail(coord, self.get_path());
		if detail_spr:
			# Some Details like Peaks always start Visible,
			# so we Skip them.
			if detail_spr.modulate.a >= 1:
				_skip_fade = true;
			else:
				detail_spr.show();
				Fader.Fade(detail_spr, Fader.Phase.IN, .5);
				# Marking
				var marking_spr:Sprite2D = _mapGen.Get_Spr_Marking(coord, self.get_path());
				Fader.Fade(marking_spr, Fader.Phase.OUT, .5);


func _Reset_Reveal(coord:Vector2) -> void:
	
	var secret_spr:Sprite2D = _mapGen.Get_Spr_Secret(coord, self.get_path());
	if secret_spr:
		# Secret
		Fader.Fade(secret_spr, Fader.Phase.OUT, .5);
		# Detail
		var detail_spr:Sprite2D = _mapGen.Get_Spr_Detail(coord, self.get_path());
		if detail_spr:
			Fader.Fade(detail_spr, Fader.Phase.IN, .5);
		# Terrain
		var terrain_spr = _mapGen.Get_TerrainSprite(coord, self.get_path());
		Fader.Colour_Fade(terrain_spr, Color.WHITE, .5);
	else:
		var detail_spr:Sprite2D = _mapGen.Get_Spr_Detail(coord, self.get_path());
		if detail_spr:
			if _skip_fade:
				_skip_fade = false;
			else:
				Fader.Fade(detail_spr, Fader.Phase.OUT, .5);
				# Marking
				var marking_spr:Sprite2D = _mapGen.Get_Spr_Marking(coord, self.get_path());
				Fader.Fade(marking_spr, Fader.Phase.IN, .5);
