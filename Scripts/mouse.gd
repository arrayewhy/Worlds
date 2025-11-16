extends Node2D

@export var _mapGen:Node2D;

#var _terrain_lifters:Dictionary;

#TEMPORARY
# Why do we need this signal?
# Why not just have scripts check Input as usual?
signal Left_Click(mouse_coord:Vector2);


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("Left-Click"):
		
		Left_Click.emit(get_global_mouse_position());
		
		# Play Ship Horn Sound on Click
		
		var gPos:Vector2 = World.Coord_OnGrid(get_global_mouse_position());
		var idx:int = World.Convert_Coord_To_Index(gPos);
		if _mapGen.Get_Marking(idx, self.get_path()) == Map_Data.Marking.BOAT:
			SoundMaster.Ship_Horn();
		
		# Get Mouse Position on Grid
		#var mouse_coord:Vector2 = World.Coord_OnGrid(get_global_mouse_position());


# Lifter ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


#func _Do_Terrain_Lifter(mouse_coord:Vector2) -> void:
	#if _terrain_lifters.has(mouse_coord):
		#return;
	#
	#var treasureType:int = _mapGen.Get_Buried(World.Convert_Coord_To_Index(mouse_coord), self.get_path());
	#
	#if treasureType < 0:
		#return;
	#
	#var spr:Sprite2D = _mapGen.Get_TerrainSprite(mouse_coord, self.get_path());
	#
	#if !spr:
		#return;
	#
	#var lifter:Terrain_Lifter = Terrain_Lifter.new(spr, mouse_coord, treasureType, get_global_mouse_position().y);
	#self.add_child(lifter);
	#
	## Record Terrain Lifter
	#_terrain_lifters.set(mouse_coord, lifter);
	#
	#lifter.Remove.connect(_Remove_Terrain_Lifter);


#func _Remove_Terrain_Lifter(ori_pos:Vector2) -> void:
	#_terrain_lifters.erase(ori_pos);
