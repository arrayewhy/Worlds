extends Node2D

@onready var _mapGen:Node2D = %map_generator;

var _terrain_lifters:Dictionary;


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Left-Click"):
		
		# Get Mouse Position on Grid
		var mousePos:Vector2 = World.Coord_OnGrid(get_global_mouse_position());
		
		if _terrain_lifters.has(mousePos):
			return;
		
		var treasureType:int = _mapGen.Get_Buried(World.Convert_Coord_To_Index(mousePos), self.get_path());
		
		if treasureType < 0:
			return;
		
		var spr:Sprite2D = _mapGen.Get_TerrainSprite(mousePos, self.get_path());
		
		if !spr:
			return;
		
		var lifter:Terrain_Lifter = Terrain_Lifter.new(spr, mousePos, treasureType, get_global_mouse_position().y);
		self.add_child(lifter);
		
		# Record Terrain Lifter
		_terrain_lifters.set(mousePos, lifter);
		
		lifter.Remove.connect(_Remove_Lifter);


func _Remove_Lifter(ori_pos:Vector2) -> void:
	_terrain_lifters.erase(ori_pos);
