class_name Terrain_Lifter extends Node2D

var _master:Node2D = get_parent();

var _spr:Sprite2D;
var _ori_pos:Vector2;
var _ori_parent:Node2D;

var _treasure_sprite:Sprite2D
var _treasure_ori_pos:Vector2;
#var _treasure_offset:float = World.CellSize * 12;
var _treasure_offset:float = pow(World.CellSize, 2);

var _last_mousePosY:float;

signal Remove(ori_pos:Vector2);


func _init(terrainSpr:Sprite2D, start_pos:Vector2, treasure:int, mousePosY:float) -> void:
	
	_spr = terrainSpr;
	_ori_pos = start_pos;
	_ori_parent = terrainSpr.get_parent();
	
	# Parent the Terrain Sprite to This Node so it shows in Front of other sprites.
	_spr.reparent(self);
	
	_spr.rotation_degrees = 0;
	
	# Treasure Sprite
	
	_treasure_sprite = World.Create_Sprite(10, 0);
	
	_treasure_sprite.modulate = Color.BLACK;
	_treasure_sprite.position = _spr.position;
	_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize + pow(World.CellSize, 1.8);
	
	_ori_parent.add_child(_treasure_sprite);
	
	_last_mousePosY = mousePosY;


func _process(delta: float) -> void:
		
		var mouseDelta:float = abs(get_global_mouse_position().y - _last_mousePosY);
		_last_mousePosY = get_global_mouse_position().y;
		
		if Input.is_action_pressed("Left-Click") && mouseDelta < 2:
			
			if _spr.position.y <= _ori_pos.y - World.CellSize:
				
				set_process(false);
				
				_spr.position.y = _ori_pos.y - World.CellSize;
				_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize + _treasure_offset;
				
				World.Signal_Replace_Terrain_Sprite(
					World.Convert_Coord_To_Index(_ori_pos), Map_Data.Terrain.HOLE, _treasure_sprite, self.get_path());
				
				var fadeTween:Tween = create_tween();
				fadeTween.tween_property(_spr, "modulate:a", 0, .5);
				
				await fadeTween.finished;
				
				# Signal Parent to Remove Records of this terrain_lifter,
				# Allowing for this Terrain Sprite to be Lifted.
				Remove.emit(_ori_pos);
				
				self.queue_free();
				
				#_treasure_sprite.queue_free();
				
				return;
		
			# Pull Upwards
			if get_global_mouse_position().y <= _ori_pos.y:
				
				_spr.position.y += (get_global_mouse_position().y - _spr.position.y) * 4 * delta;
				#_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize + pow(World.CellSize, 1.8);
				_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize + _treasure_offset;
				#_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize;
				_treasure_sprite.modulate.v = abs(_spr.position.y - _ori_pos.y) * .05;
				_treasure_sprite.modulate.v = clamp(_treasure_sprite.modulate.v, 0, 1);
				
			# If the Mouse is Below the Terrain Sprite's Original Position,
			# Slide it back down.
			else:
				_spr.position.y += (_ori_pos.y - _spr.position.y) * 4 * delta;
				_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize + _treasure_offset;
				_treasure_sprite.modulate.v = abs(_spr.position.y - _ori_pos.y) * .05;
				_treasure_sprite.modulate.v = clamp(_treasure_sprite.modulate.v, 0, 1);
				#_treasure_sprite.offset.y = (_spr.position.y - _ori_pos.y) * World.CellSize + pow(World.CellSize, 1.8);
				
			return;
			
		set_process(false);
		
		var dropTween:Tween = create_tween();
		dropTween.set_trans(Tween.TRANS_BOUNCE);
		dropTween.set_ease(Tween.EASE_OUT);
		dropTween.set_parallel(true);
		dropTween.tween_property(_spr, "position:y", _ori_pos.y, .5);
		dropTween.tween_property(_treasure_sprite, "offset:y", _treasure_offset, .5);
		dropTween.tween_property(_treasure_sprite, "modulate:v", 0, .5)
		
		await dropTween.finished;
		
		_spr.reparent(_ori_parent);
		
		# Signal Parent to Remove Records of this terrain_lifter,
		# Allowing for this Terrain Sprite to be Lifted.
		Remove.emit(_ori_pos);
		
		self.queue_free();
		
		_treasure_sprite.queue_free();
		
		return;
