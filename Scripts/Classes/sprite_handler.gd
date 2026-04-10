class_name Sprite_Handler

const _terrain_sprites:Texture2D = preload("res://Sprites/terrain_sprites.png");
const _spriteSheet:Texture2D = preload("res://Sprites/sparks_in_the_dark.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");

const _fadeInOut:Shader = preload("res://Shaders/fadeInOut.gdshader");
const _wiggle:Shader = preload("res://Shaders/wiggle.gdshader");

# Water Depth Alpha
const _waterDepth:float = 4.0;
const _valueThresh:float = 1.0 / _waterDepth;


static func Terr_Sprites_From_Terr_Data(t_data:Array[Map_Data.Terrain], cont_terr_spr:Node2D, debug:bool = false) -> Array[Sprite2D]:
	
	var spr_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for t in t_data:
		
		# Create Sprite
		var spr:Sprite2D = Create_Sprite(0, 0, 1, _terrain_sprites);
		cont_terr_spr.add_child(spr);
		
		spr = Configure_TerrainSprite_LandAndSea(spr, t);
		
		# Position Terrain Sprite
		spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
		spr.position += Vector2.ONE * randf_range(-.4, .4);
		spr.rotation += randf_range(-.0625, .0625);
		
		# Add Sprite to Array
		spr_array.append(spr);
		
		# Set Next sprite Position
		currX += 1;
		if currX >= World.MAP_UNIT_WIDTH:
			currX = 0;
			currY += 1;
	
	if debug: print_debug("Terr_Sprites_From_Terr_Data, Terrain: ", spr_array.size());
	return spr_array;


static func Configure_TerrainSprite_LandAndSea(spr:Sprite2D, terrainType:Map_Data.Terrain) -> Sprite2D:
	
	var new_spr:Sprite2D = spr;
	
	match terrainType:
		Map_Data.Terrain.MOUNTAIN:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 2; # Grey
			new_spr.modulate.v -= randf_range(0, 0.25);
			new_spr.scale *= randf_range(1.125, 1.3);
		#Map_Data.Terrain.MOUNTAIN_PATH:
			#new_spr.region_rect.position.x = World.Spr_Reg_Size * 2; # Grey
			#new_spr.modulate.v -= randf_range(0, 0.25);
		Map_Data.Terrain.FOREST:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 3; # Green
			new_spr.modulate.v -= .125;
			new_spr.modulate.v -= randf_range(0.125, 0.2);
			new_spr.scale *= randf_range(1.125, 1.5);
		Map_Data.Terrain.GROUND:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 3; # Green
			new_spr.modulate.v -= randf_range(0, 0.125);
		Map_Data.Terrain.SHORE:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 4; # Sand Brown
			new_spr.modulate.a -= randf_range(0, 0.125);
		Map_Data.Terrain.SHALLOW:
			new_spr.modulate.a = _valueThresh * 1.9 - randf_range(0, 0.03125);
			new_spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.SEA:
			new_spr.modulate.a = _valueThresh * 1.25 - randf_range(0, 0.03125);
			new_spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.OCEAN:
			new_spr.modulate.a = _valueThresh * .8 - randf_range(0, 0.03125);
			new_spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.DEPTHS:
			new_spr.modulate.a = _valueThresh * .5 - randf_range(0, 0.03125);
			new_spr.scale *= randf_range(1, 1.125);
		Map_Data.Terrain.ABYSS:
			new_spr.modulate.a = _valueThresh * .3;
			new_spr.scale *= randf_range(1, 1.125);
			
		# Specials
		Map_Data.Terrain.TEMPLE_BROWN:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 9;
		Map_Data.Terrain.HOLE:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 10; # Brown Box
		Map_Data.Terrain.Null:
			new_spr.region_rect.position.x = World.Spr_Reg_Size * 8; # Fucshia
			
		_:
			print_debug("\nTerrain Data contains Invalid Data");
		
	return new_spr;


static func MarkingSprites_From_MarkingData(m_data:Array[Map_Data.Marking], t_data:Array[Map_Data.Terrain],
	cont_showOnZoom:Node2D, cont_hideOnZoom:Node2D, cont_alwaysShow:Node2D, cont_treasures:CanvasLayer,
	debug:bool = false) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m_idx in m_data.size():
		
		var spr:Sprite2D = null;
		
		match m_data[m_idx]:
		
			Map_Data.Marking.HOUSE:
				spr = Create_Sprite(2, 6, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.scale *= 0.75;
				
				if t_data[m_idx] == Map_Data.Terrain.SHORE:
					spr.modulate = Color.BLACK;
			
			Map_Data.Marking.OLD_HOUSE:
				spr = Create_Sprite(2, 6, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.scale *= 0.75;
				spr.name = Map_Data.Marking.keys()[Map_Data.Marking.OLD_HOUSE];
				
				if t_data[m_idx] == Map_Data.Terrain.SHORE:
					spr.modulate = Color.BLACK;
			
			Map_Data.Marking.FOREST_FIRE:
				spr = Create_Sprite(2, 4, 1, _glyphs);
				cont_alwaysShow.add_child(spr);
			
			Map_Data.Marking.MOUNTAIN_ENTRANCE:
				spr = Create_Sprite(9, 1, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale *= randf_range(1, 1.75);
				spr.scale /= 2;
			
			Map_Data.Marking.PEAK:
				spr = Create_Sprite(3, 6, 1);
				cont_showOnZoom.add_child(spr);
				spr.scale *= randf_range(1, 1.5);
			
			Map_Data.Marking.MINI_MOUNT:
				spr = Create_Sprite(9, 1, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale *= randf_range(1, 1.75);
				spr.scale /= 2;
				
			Map_Data.Marking.HILL:
				spr = Create_Sprite(5, 7);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				
			Map_Data.Marking.GRASS:
				if randi_range(0, 4) > 2: spr = Create_Sprite(8, 6, 1, _glyphs);
				else: spr = Create_Sprite(1, 8);
				cont_showOnZoom.add_child(spr);
				spr.scale *= .8;
				
			Map_Data.Marking.TREE:
				spr = Create_Sprite(7, 6);
				cont_showOnZoom.add_child(spr);
				#spr.scale.x *= randf_range(.9, 1.125);
				spr.scale.y *= randf_range(.9, 1.125);
				spr.rotation += randf_range(-.125, .125);
				spr.name = "Tree";
				
			Map_Data.Marking.LIGHTHOUSE:
				#s_array.append(null);
				spr = Create_Sprite(0, 11, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				# Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = spr.position;
				#spr.add_child(lamp);
				#isLighthouse = true;
				
			Map_Data.Marking.SHELL:
				spr = Create_Sprite(6, 9, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale = spr.scale / 4 * 3;
			
			Map_Data.Marking.MESSAGE_BOTTLE:
				spr = Create_Sprite(14, 8, 1, _glyphs);
				cont_alwaysShow.add_child(spr);
				spr.add_child(Drift.new());
				spr.rotation_degrees = randf_range(15, 45);
				
			Map_Data.Marking.SMALL_FISH:
				spr = Create_Sprite(0, 7);
				cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 10.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.BIG_FISH:
				spr = Create_Sprite(1, 7);
				cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 5.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.JETTY:
				spr = Create_Sprite(13, 12, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				
			Map_Data.Marking.TREASURE:
				spr = Create_Sprite(9, 8);
				cont_treasures.add_child(spr);
				#spr.modulate = Color.BLACK;
				spr.material = ShaderMaterial.new();
				spr.material.shader = _fadeInOut;
			
			Map_Data.Marking.TEMPLE:
				spr = Create_Sprite(13, 11, 1, _glyphs);
				#spr = Create_Sprite(10, 0);
				cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.ORANGE;
			
			Map_Data.Marking.GOLD:
				s_array.append(null);
			
			Map_Data.Marking.HOBBIT_HOUSE:
				spr = Create_Sprite(5, 7);
				cont_hideOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
			
			Map_Data.Marking.BOAT:
				spr = Create_Sprite(0, 6);
				cont_showOnZoom.add_child(spr);
			
			Map_Data.Marking.SHIP:
				spr = Create_Sprite(randi_range(8, 10), 7);
				cont_alwaysShow.add_child(spr);
				spr.modulate = Color(.25, .5, .5, 1);
				spr.modulate.a = .25;
			
			Map_Data.Marking.Null:
				s_array.append(null);
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(m_data[m_idx]));
			
		# Position Marking
		
		if spr:
			
			spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			# Make Mark Y-Sort Behind Player
			spr.position.y -= .03125;
			
			# Hide Sprite to Reveal on Proximity
			spr.hide();
			
			# Add Sprite to Array
			s_array.append(spr);
			
		# Set Next marking Position
		currX += 1;
		if currX >= World.MAP_UNIT_WIDTH:
			currX = 0;
			currY += 1;
			
	if debug: print_debug("MarkingSprites_From_MarkingData, Markings: ", s_array.size());
	return s_array;


static func DetailSprites_From_MarkingData(m_data:Array[Map_Data.Marking], cont_showOnZoom:Node2D, debug:bool = false) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m_idx in m_data.size():
		
		var spr:Sprite2D = null;
		
		match m_data[m_idx]:
		
			Map_Data.Marking.HOUSE:
				
				spr = Create_Sprite(randi_range(2, 4), 14);
				cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position.y = currY * World.CellSize - randf_range(World.CellSize / 3, World.CellSize / 2);
				spr.scale *= randf_range(1, 1.125);
				#spr.scale *= 0.75;
				spr.rotation += randf_range(-.125, .125);
				
				#spr.modulate.a = 0;
			
			Map_Data.Marking.OLD_HOUSE:
				
				spr = Create_Sprite(4, 14);
				cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position.y = currY * World.CellSize - randf_range(World.CellSize / 3, World.CellSize / 2);
				spr.scale *= randf_range(1, 1.125);
				#spr.scale *= 0.75;
				spr.rotation += randf_range(-.125, .125);
				
			Map_Data.Marking.MOUNTAIN_ENTRANCE:
				spr = Create_Sprite(1, 3, 1, _glyphs);
				cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.modulate = Color.BLACK;
				
				#spr.modulate.a = 0;
				#spr.offset = _sprite_array_Terrain[m_idx].offset;
				
			#Map_Data.Marking.TENT:
				#pass;
				
			Map_Data.Marking.PEAK:
				#spr = Create_Sprite(3, 6);
				#cont_showOnZoom.add_child(spr);
				#spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				#spr.scale *= 1.5;
				##spr.rotation += randf_range(-.125, .125);
				#spr.name = "Peak";
				pass;
				
			Map_Data.Marking.MINI_MOUNT:
				pass;
				
			Map_Data.Marking.HILL:
				pass;
			
			Map_Data.Marking.GRASS:
				pass;
				
			Map_Data.Marking.TREE:
				pass;
				
			Map_Data.Marking.LIGHTHOUSE:
				
				spr = Create_Sprite(7, 12, 2);
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
				
				spr = Create_Sprite(2, 7);
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
				spr = Create_Sprite(7, 7);
				cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.modulate = Color.BLACK;
			
			#Map_Data.Marking.SEAGRASS:
				#pass;
			
			Map_Data.Marking.BOAT:
				pass;
			
			Map_Data.Marking.SHIP:
				pass;
				
			Map_Data.Marking.Null:
				pass;
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(m_data[m_idx]));
		
		if spr:
			# Hide Sprite to Reveal on Proximity
			spr.hide();
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= World.MAP_UNIT_WIDTH:
			currX = 0;
			currY += 1;
			
	if debug: print_debug("_DetailSprites_From_MarkingData, Details: ", s_array.size());
	return s_array;


#static func SecretSprites_From_SecretData(s_data:Array[Map_Data.Secrets],
	#cont_secrets:Node2D, debug:bool = false) -> Array[Sprite2D]:
	#
	#var s_array:Array[Sprite2D];
	#
	#var currX:int = 0;
	#var currY:int = 0;
	#
	#for s_idx in s_data.size():
		#
		#var spr:Sprite2D = null;
		#
		#match s_data[s_idx]:
			#
			#Map_Data.Secrets.DRAGON:
				#spr = Create_Sprite(9, 1);
				#cont_secrets.add_child(spr);
				#spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			#
			#_:
				#pass;
		#
		#if spr:
			## Hide Sprite to Reveal on Proximity
			#spr.hide();
		#
		#s_array.append(spr);
		#
		## Set Next Detail Position
		#currX += 1;
		#if currX >= World.MAP_UNIT_WIDTH:
			#currX = 0;
			#currY += 1;
		#
	#if debug: print_debug("_SecretSprites_From_SecretData, Secrets: ", s_array.size());
	#return s_array;


static func Create_Sprite(regPosX:float, regPosY:float, cells_y:int = 1, tex:Texture2D = _spriteSheet) -> Sprite2D:
	
	var spr:Sprite2D = Sprite2D.new();
	spr.texture = tex;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size);
	spr.region_rect.position = Vector2(regPosX, regPosY) * World.Spr_Reg_Size;
	spr.scale /= World.CellSize;
	
	spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size * cells_y);
	
	if cells_y > 1:
		var displace_units:float = float(cells_y) / 2;
		spr.offset.y -= World.CellSize * 8 * displace_units;
	
	return spr;
