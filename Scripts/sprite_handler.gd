class_name Sprite_Handler

const _terrain_sprites:Texture2D = preload("res://Sprites/terrain_sprites.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");

const _fadeInOut:Shader = preload("res://Shaders/fadeInOut.gdshader");
const _wiggle:Shader = preload("res://Shaders/wiggle.gdshader");

# Water Depth Alpha
const _waterDepth:float = 4.0;
const _valueThresh:float = 1.0 / _waterDepth;


static func TerrainSprites_From_TerrainData(terrainData:Array[Map_Data.Terrain],
	cont_terrainSprites:Node2D, debug:bool = false) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for t in terrainData:
		
		#if t == Map_Data.Terrain.ABYSS:
			#s_array.append(null);
		#else:
		# Create Sprite
		
		var spr:Sprite2D = World.Create_Sprite(0, 0, 1, _terrain_sprites);
		cont_terrainSprites.add_child(spr);
		
		Configure_TerrainSprite_LandAndSea(spr, t);
		
		# Position Terrain Sprite
		
		spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
		spr.position += Vector2.ONE * randf_range(-.4, .4);
		spr.rotation += randf_range(-.0625, .0625);
		
		spr.modulate.a = 0;
		spr.hide();
		
		s_array.append(spr);
		
		# Set Next sprite Position
		
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
	
	if debug: print_debug("_TerrainSprites_From_TerrainData, Terrain: ", s_array.size());
	return s_array;


static func Configure_TerrainSprite_LandAndSea(spr:Sprite2D, terrainType:Map_Data.Terrain) -> void:
	
	match terrainType:
		Map_Data.Terrain.MOUNTAIN:
			spr.region_rect.position.x = World.Spr_Reg_Size * 2; # Grey
			spr.modulate.v -= randf_range(0, 0.25);
			spr.scale *= randf_range(1.125, 1.3);
		Map_Data.Terrain.MOUNTAIN_PATH:
			spr.region_rect.position.x = World.Spr_Reg_Size * 2; # Grey
			spr.modulate.v -= randf_range(0, 0.25);
			#spr.scale *= randf_range(1.125, 1.3);
		Map_Data.Terrain.FOREST:
			#spr.region_rect.position.x = World.Spr_Reg_Size * 2;
			spr.region_rect.position.x = World.Spr_Reg_Size * 3; # Green
			spr.modulate.v -= .125;
			spr.modulate.v -= randf_range(0.125, 0.2);
			spr.scale *= randf_range(1.125, 1.5);
		Map_Data.Terrain.GROUND:
			spr.region_rect.position.x = World.Spr_Reg_Size * 3; # Green
			spr.modulate.v -= randf_range(0, 0.125);
			#spr.modulate.r -= .25;
			#spr.modulate.b -= .25;
			#spr.modulate.s += 1;
			#spr.modulate.v -= .2;
		Map_Data.Terrain.SHORE:
			spr.region_rect.position.x = World.Spr_Reg_Size * 4; # Sand Brown
			spr.modulate.a -= randf_range(0, 0.125);
			#spr.region_rect.position.x = World.Spr_Reg_Size * 3;
			#spr.modulate.v -= .2;
		Map_Data.Terrain.SHALLOW:
			#spr.region_rect.position.x = World.Spr_Reg_Size * 4; # Sand Brown
			#spr.modulate.r -= .5;
			#spr.modulate.g -= .1;
			#spr.modulate.v = _valueThresh * 1.5;
			spr.modulate.a = _valueThresh * 1.9 - randf_range(0, 0.03125);
			spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.SEA:
			#spr.region_rect.position.x = World.Spr_Reg_Size * 4; # Sand Brown
			#spr.modulate.r -= .6;
			#spr.modulate.g -= .2;
			spr.modulate.a = _valueThresh * 1.25 - randf_range(0, 0.03125);
			spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.OCEAN:
			spr.modulate.a = _valueThresh * .8 - randf_range(0, 0.03125);
			#spr.modulate.a = _valueThresh * 1.0 - randf_range(0, .125);
			#spr.modulate.g -= .25;
			spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.DEPTHS:
			spr.modulate.a = _valueThresh * .5 - randf_range(0, 0.03125);
			spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.ABYSS:
			spr.modulate.a = _valueThresh * .3;
			spr.scale *= randf_range(1, 1.125);
			#pass;
			
		# Specials
		#Map_Data.Terrain.SEA_GREEN:
			#spr.modulate.a = _valueThresh * 1.6 - randf_range(0, .125);
			#var rand:float = randf_range(.125, .25);
			#spr.modulate.b -= rand;
		Map_Data.Terrain.TEMPLE_BROWN:
			#spr.region_rect.position.x = World.Spr_Reg_Size * 5;
			spr.region_rect.position.x = World.Spr_Reg_Size * 9; # Brown
		Map_Data.Terrain.DOCK:
			spr.region_rect.position.x = World.Spr_Reg_Size * 9; # Brown
		Map_Data.Terrain.WATER_COAST:
			spr.region_rect.position.x = World.Spr_Reg_Size * 4; # Sand Brown
			spr.modulate.r -= .5;
			spr.modulate.a = _valueThresh * 1.75 - randf_range(0, .125);
			
		Map_Data.Terrain.HOLE:
			spr.region_rect.position.x = World.Spr_Reg_Size * 10; # Brown Box
			
		Map_Data.Terrain.Null:
			spr.region_rect.position.x = World.Spr_Reg_Size * 8; # Fucshia
			
		_:
			print_debug("\nTerrain Data contains Invalid Data");


static func MarkingSprites_From_MarkingData(markingData:Array[Map_Data.Marking],
	cont_showOnZoom:Node2D, cont_hideOnZoom:Node2D, cont_alwaysShow:Node2D, cont_treasures:CanvasLayer,
	debug:bool = false) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m_idx in markingData.size():
		
		var spr:Sprite2D = null;
		
		match markingData[m_idx]:
		
			Map_Data.Marking.HOUSE:
				spr = World.Create_Sprite(2, 6, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.scale *= 0.75;
			
			Map_Data.Marking.MOUNTAIN_ENTRANCE:
				s_array.append(null);
			
			Map_Data.Marking.PEAK:
				spr = World.Create_Sprite(9, 1, 1, _glyphs);
				cont_hideOnZoom.add_child(spr);
				spr.scale *= randf_range(1, 1.5);
				spr.modulate = Color.BLACK;
			
			Map_Data.Marking.MINI_MOUNT:
				spr = World.Create_Sprite(9, 1, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale *= randf_range(1, 1.75);
				spr.scale /= 2;
				
			Map_Data.Marking.HILL:
				spr = World.Create_Sprite(5, 7);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				
			Map_Data.Marking.TREE:
				spr = World.Create_Sprite(7, 6);
				cont_showOnZoom.add_child(spr);
				#spr.scale.x *= randf_range(.9, 1.125);
				spr.scale.y *= randf_range(.9, 1.125);
				spr.rotation += randf_range(-.125, .125);
				spr.name = "Tree";
				
			Map_Data.Marking.LIGHTHOUSE:
				#s_array.append(null);
				spr = World.Create_Sprite(0, 11, 1, _glyphs);
				cont_hideOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				# Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = spr.position;
				#spr.add_child(lamp);
				#isLighthouse = true;
				
			Map_Data.Marking.SHELL:
				spr = World.Create_Sprite(6, 9, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale = spr.scale / 4 * 3;
			
			Map_Data.Marking.MESSAGE_BOTTLE:
				spr = World.Create_Sprite(14, 8, 1, _glyphs);
				cont_alwaysShow.add_child(spr);
				spr.add_child(Drift.new());
				spr.rotation_degrees = randf_range(15, 45);
				
			Map_Data.Marking.SMALL_FISH:
				spr = World.Create_Sprite(0, 7);
				cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 10.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.BIG_FISH:
				spr = World.Create_Sprite(1, 7);
				cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 5.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.JETTY:
				spr = World.Create_Sprite(13, 12, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				
			Map_Data.Marking.TREASURE:
				spr = World.Create_Sprite(9, 8);
				cont_treasures.add_child(spr);
				#spr.modulate = Color.BLACK;
				spr.material = ShaderMaterial.new();
				spr.material.shader = _fadeInOut;
			
			Map_Data.Marking.TEMPLE:
				spr = World.Create_Sprite(13, 11, 1, _glyphs);
				#spr = World.Create_Sprite(10, 0);
				cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.ORANGE;
			
			Map_Data.Marking.GOLD:
				s_array.append(null);
			
			Map_Data.Marking.HOBBIT_HOUSE:
				spr = World.Create_Sprite(5, 7);
				cont_hideOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
			
			Map_Data.Marking.BOAT:
				spr = World.Create_Sprite(randi_range(8, 10), 7);
				cont_alwaysShow.add_child(spr);
				spr.modulate = Color(.25, .5, .5, 1);
				#spr.modulate = Color.BLACK;
				spr.modulate.a = .25;
			
			Map_Data.Marking.Null:
				s_array.append(null);
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(markingData[m_idx]));
			
		# Position Marking
		
		if spr:
			
			spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			# Make Mark Y-Sort Behind Player
			spr.position.y -= .03125;
			#marking.position += Vector2.ONE * randf_range(-.4, .4);
			
			spr.modulate.a = 0;
			spr.hide();
			
			s_array.append(spr);
			
		# Set Next marking Position
		
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
			
	if debug: print_debug("_MarkingSprites_From_MarkingData, Markings: ", s_array.size());
	return s_array;


static func DetailSprites_From_MarkingData(markingData:Array[Map_Data.Marking],
	cont_showOnZoom:Node2D, debug:bool = false) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m_idx in markingData.size():
		
		var spr:Sprite2D = null;
		
		match markingData[m_idx]:
		
			Map_Data.Marking.HOUSE:
				
				spr = World.Create_Sprite(randi_range(2, 4), 14);
				cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position.y = currY * World.CellSize - randf_range(World.CellSize / 3, World.CellSize / 2);
				spr.scale *= randf_range(1, 1.125);
				#spr.scale *= 0.75;
				spr.rotation += randf_range(-.125, .125);
				
				spr.modulate.a = 0;
				
			Map_Data.Marking.MOUNTAIN_ENTRANCE:
				spr = World.Create_Sprite(1, 3, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.modulate = Color.BLACK;
				
				spr.modulate.a = 0;
				#spr.offset = _sprite_array_Terrain[m_idx].offset;
				
			#Map_Data.Marking.TENT:
				#pass;
				
			Map_Data.Marking.PEAK:
				spr = World.Create_Sprite(3, 6);
				cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.scale *= 1.5;
				#spr.rotation += randf_range(-.125, .125);
				spr.name = "Peak";
				
			Map_Data.Marking.MINI_MOUNT:
				pass;
				
			Map_Data.Marking.HILL:
				pass;
				
			Map_Data.Marking.TREE:
				pass;
				
			Map_Data.Marking.LIGHTHOUSE:
				
				spr = World.Create_Sprite(7, 12, 2);
				cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.position.y -= World.CellSize / 2;
				
			Map_Data.Marking.SHELL:
				pass;
			Map_Data.Marking.SMALL_FISH:
				pass;
			Map_Data.Marking.BIG_FISH:
				pass;
			Map_Data.Marking.JETTY:
				pass;
			Map_Data.Marking.TREASURE:
				pass;
			#Map_Data.Marking.WHALE:
				#pass;
			#Map_Data.Marking.SEAGRASS:
				#pass;
			Map_Data.Marking.TEMPLE:
				pass;
				
			Map_Data.Marking.GOLD:
				
				spr = World.Create_Sprite(2, 7);
				cont_showOnZoom.add_child(spr);
				
				spr.modulate.a = _valueThresh * 1 + randf_range(-0.0625, .0625);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				#spr.position -= Vector2.ONE * randf_range(0, World.CellSize / 1.5);
				spr.scale *= randf_range(-1, 1.125);
				spr.rotation += randf_range(-.125, .125);
			
			Map_Data.Marking.MESSAGE_BOTTLE:
				pass;
			
			Map_Data.Marking.HOBBIT_HOUSE:
				spr = World.Create_Sprite(7, 7);
				cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.modulate = Color.BLACK;
			
			#Map_Data.Marking.SEAGRASS:
				#pass;
			
			Map_Data.Marking.BOAT:
				pass;
				
			Map_Data.Marking.Null:
				pass;
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(markingData[m_idx]));
		
		if spr:
			spr.modulate.a = 0;
			spr.hide();
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
			
	if debug: print_debug("_DetailSprites_From_MarkingData, Details: ", s_array.size());
	return s_array;


static func SecretSprites_From_SecretData(secretData:Array[Map_Data.Secrets],
	cont_secrets:Node2D, debug:bool = false) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for s_idx in secretData.size():
		
		var spr:Sprite2D = null;
		
		match secretData[s_idx]:
			
			Map_Data.Secrets.DRAGON:
				spr = World.Create_Sprite(9, 1);
				cont_secrets.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			
			_:
				pass;
		
		if spr:
			spr.modulate.a = 0;
			spr.hide();
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
		
	if debug: print_debug("_SecretSprites_From_SecretData, Secrets: ", s_array.size());
	return s_array;
