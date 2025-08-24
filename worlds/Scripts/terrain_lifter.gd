class_name Terrain_Lifter extends Node2D

var _master:Node2D = get_parent();

var _spr:Sprite2D;
var _ori_pos:Vector2;
var _ori_parent:Node2D;

signal Remove(ori_pos:Vector2);


func _init(spr:Sprite2D, start_pos:Vector2) -> void:
	
	_spr = spr;
	_ori_pos = start_pos;
	_ori_parent = spr.get_parent();
	# Parent the Terrain Sprite to This Node so it shows in Front of other sprites.
	_spr.reparent(self);


func _process(delta: float) -> void:
		
		if Input.is_action_pressed("Left-Click"):
		
			# Pull Upwards
			if get_global_mouse_position().y <= _ori_pos.y:
				_spr.position.y += (get_global_mouse_position().y - _spr.position.y) * 3 * delta;
			# If the Mouse is Below the Terrain Sprite's Original Position,
			# Slide it back down.
			else:
				_spr.position.y += (_ori_pos.y - _spr.position.y) * 4 * delta;
		
		else:
			
			set_process(false);
			
			var dropTween:Tween = create_tween();
			dropTween.tween_property(_spr, "position:y", _ori_pos.y, 1);
			
			await dropTween.finished;
			
			_spr.reparent(_ori_parent);
			
			# Signal Parent to Remove Records of this terrain_lifter,
			# Allowing for this Terrain Sprite to be Lifted.
			Remove.emit(_ori_pos);
			
			self.queue_free();
