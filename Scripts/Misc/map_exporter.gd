extends Node

@export var _map_gen:Node2D;

@export var _save_terrain_map:bool;
@export var _map_name:String;

@export var _save_marking_map:bool;


func _process(_delta: float) -> void:
	
	if _save_terrain_map:
		
		if _map_name == "":
			printerr("map_exporter: Map Name NOT set.");
			_save_terrain_map = false;
			return;
		
		_Export_Terrain_Map(_map_gen.Get_Terrain_Data(self.get_path()));
		
		_save_terrain_map = false;
	
	elif _save_marking_map:
		
		if _map_name == "":
			printerr("map_exporter: Map Name NOT set.");
			_save_marking_map = false;
			return;
		
		_Export_Marking_Map(_map_gen.Get_Marking_Data(self.get_path()));
		
		_save_marking_map = false;


func _Export_Terrain_Map(terrain_data:Array[Map_Data.Terrain]) -> void:
	
	# Get the Width of the Map,
	# assuming that the map is a Square.
	var map_diameter:float = sqrt(terrain_data.size());
	
	var img:Image = Image.create(map_diameter, map_diameter, false, Image.FORMAT_RGB8);
	
	var currIdx:int = 0;
	
	for y in map_diameter:
		for x in map_diameter:
			
			var col:Color;
			
			match terrain_data[currIdx]:
				
				Map_Data.Terrain.Null:
					col = Color.from_rgba8(255, 0, 255, 255);

				#DEBUG
				Map_Data.Terrain.HOLE:
					col = Color.from_rgba8(200, 100, 0, 255);
				
				# Land
				Map_Data.Terrain.MOUNTAIN:
					col = Color.from_rgba8(170, 170, 170, 255);
				#Map_Data.Terrain.MOUNTAIN_PATH:
					#col = Color.from_rgba8(220, 220, 200, 255);
				Map_Data.Terrain.FOREST:
					col = Color.from_rgba8(70, 130, 90, 255);
				Map_Data.Terrain.GROUND:
					col = Color.from_rgba8(110, 170, 110, 255);
				Map_Data.Terrain.SHORE:
					col = Color.from_rgba8(210, 210, 150, 255);
				# Water
				Map_Data.Terrain.SHALLOW:
					col = Color.from_rgba8(100, 180, 190, 255);
				Map_Data.Terrain.SEA:
					col = Color.from_rgba8(70, 140, 160, 255);
				Map_Data.Terrain.OCEAN:
					col = Color.from_rgba8(50, 100, 120, 255);
				Map_Data.Terrain.DEPTHS:
					col = Color.from_rgba8(30, 60, 80, 255);
				Map_Data.Terrain.ABYSS:
					col = Color.from_rgba8(20, 30, 60, 255);
				
				# Special: Land
				Map_Data.Terrain.TEMPLE_BROWN:
					col = Color.from_rgba8(210, 60, 0, 255);
				#Map_Data.Terrain.DOCK:
					#col = Color.from_rgba8(220, 130, 0, 255);
				# Special: Water
				#SEA_GREEN,
				#Map_Data.Terrain.WATER_COAST:
					#col = Color.from_rgba8(255, 255, 0, 255);
			
			img.set_pixel(x, y, col);
			
			currIdx += 1;
	
	# Save Image to Disk
	img.save_png("res://Exports/" + _map_name + " - Terrain.png");
	print("map_exporter: Exported => " + _map_name);
	
	# Reset
	_map_name = "";


func _Export_Marking_Map(marking_data:Array[Map_Data.Marking]) -> void:
	
	# Get the Width of the Map,
	# assuming that the map is a Square.
	var map_diameter:int = sqrt(marking_data.size());
	
	var img:Image = Image.create(map_diameter, map_diameter, false, Image.FORMAT_RGB8);
	
	var currIdx:int = 0;
	
	for y in map_diameter:
		for x in map_diameter:
			
			var col:Color;
			
			match marking_data[currIdx]:
				
				Map_Data.Marking.Null:
					pass;
				Map_Data.Marking.HOUSE:
					col = Color.RED;
				Map_Data.Marking.PEAK:
					col = Color.WHITE;
				Map_Data.Marking.HILL:
					pass;
				Map_Data.Marking.GRASS:
					col = Color.GREEN;
				Map_Data.Marking.TREE:
					pass;
				Map_Data.Marking.LIGHTHOUSE:
					col = Color.ORANGE;
				Map_Data.Marking.SHELL:
					pass;
				Map_Data.Marking.SMALL_FISH:
					col = Color.SKY_BLUE;
				Map_Data.Marking.BIG_FISH:
					col = Color.CADET_BLUE;
				Map_Data.Marking.JETTY:
					col = Color.SADDLE_BROWN;
				Map_Data.Marking.TREASURE:
					col = Color.GOLDENROD;
				Map_Data.Marking.OARFISH:
					pass;
				Map_Data.Marking.TEMPLE:
					pass;
				Map_Data.Marking.GOLD:
					col = Color.GOLD;
				Map_Data.Marking.MESSAGE_BOTTLE:
					pass;
				Map_Data.Marking.MINI_MOUNT:
					pass;
				Map_Data.Marking.HOBBIT_HOUSE:
					pass;
				Map_Data.Marking.MOUNTAIN_ENTRANCE:
					pass;
				Map_Data.Marking.BOAT:
					pass;
				Map_Data.Marking.SHIP:
					pass;
				Map_Data.Marking.DRAGON:
					pass;
			
			img.set_pixel(x, y, col);
			
			currIdx += 1;
	
	# Save Image to Disk
	img.save_png("res://Exports/" + _map_name + " - Markings.png");
	print("map_exporter: Exported => " + _map_name);
	
	# Reset
	_map_name = "";
