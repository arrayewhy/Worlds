extends Node

@onready var _map_gen:Node2D = get_parent();

@export var _save_image:bool;
@export var _image_name:String;


func _process(_delta: float) -> void:
	
	if _save_image:
		
		if _image_name == "":
			printerr("map_exporter: Export Image Name NOT set.");
			_save_image = false;
			return;
		
		var terrain_data:Array[Map_Data.Terrain] = _map_gen.Get_Terrain_Data(self.get_path());
		
		var map_diameter:float = sqrt(terrain_data.size());
		
		var img:Image = Image.create(map_diameter, map_diameter, false, Image.FORMAT_RGB8);
		
		var currIdx:int = 0;
		
		for y in map_diameter:
			for x in map_diameter:
				
				var col:Color;
				
				match terrain_data[currIdx]:
					
					Map_Data.Terrain.Null:
						col = Color.MAGENTA;
	
					#DEBUG
					Map_Data.Terrain.HOLE:
						col = Color.BROWN;
					
					# Land
					Map_Data.Terrain.MOUNTAIN:
						col = Color.GRAY;
					Map_Data.Terrain.MOUNTAIN_PATH:
						col = Color.LIGHT_GRAY;
					Map_Data.Terrain.FOREST:
						col = Color.FOREST_GREEN;
					Map_Data.Terrain.GROUND:
						col = Color.GREEN;
					Map_Data.Terrain.SHORE:
						col = Color.SANDY_BROWN;
					# Water
					Map_Data.Terrain.SHALLOW:
						col = Color.SKY_BLUE;
					Map_Data.Terrain.SEA:
						col = Color.DEEP_SKY_BLUE;
					Map_Data.Terrain.OCEAN:
						col = Color.DODGER_BLUE;
					Map_Data.Terrain.DEPTHS:
						col = Color.DARK_SLATE_BLUE;
					Map_Data.Terrain.ABYSS:
						col = Color.DARK_BLUE;
					
					# Special: Land
					Map_Data.Terrain.TEMPLE_BROWN:
						col = Color.INDIAN_RED;
					Map_Data.Terrain.DOCK:
						col = Color.SADDLE_BROWN;
					# Special: Water
					#SEA_GREEN,
					Map_Data.Terrain.WATER_COAST:
						col = Color.FUCHSIA;
				
				img.set_pixel(x, y, col);
				
				currIdx += 1;
		
		img.save_png("res://Exports/" + _image_name + ".png");
		
		print("map_exporter: Image Exported => " + _image_name);
		_image_name = "";
		_save_image = false;
