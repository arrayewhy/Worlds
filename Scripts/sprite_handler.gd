extends Node2D

const _terrain_sprites:Texture2D = preload("res://Sprites/terrain_sprites.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");

const _fadeInOut:Shader = preload("res://Shaders/fadeInOut.gdshader");
const _wiggle:Shader = preload("res://Shaders/wiggle.gdshader");


func _MarkingSprites_From_MarkingData(
	markingData:Array[Map_Data.Marking], \
	_cont_showOnZoom:Node2D, \
	_cont_hideOnZoom:Node2D, \
	_cont_alwaysShow:Node2D, \
	_cont_treasures:CanvasLayer, \
	debug:bool = false
	) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m_idx in markingData.size():
		
		var spr:Sprite2D = null;
		
		match markingData[m_idx]:
		
			Map_Data.Marking.HOUSE:
				spr = World.Create_Sprite(2, 6, 1, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.scale *= 0.75;
			
			Map_Data.Marking.MOUNTAIN_ENTRANCE:
				s_array.append(null);
			
			Map_Data.Marking.PEAK:
				spr = World.Create_Sprite(9, 1, 1, _glyphs);
				_cont_hideOnZoom.add_child(spr);
				spr.scale *= randf_range(1, 1.5);
				spr.modulate = Color.BLACK;
			
			Map_Data.Marking.MINI_MOUNT:
				spr = World.Create_Sprite(9, 1, 1, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale *= randf_range(1, 1.75);
				spr.scale /= 2;
				
			Map_Data.Marking.HILL:
				spr = World.Create_Sprite(5, 7);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				
			Map_Data.Marking.TREE:
				spr = World.Create_Sprite(7, 6);
				_cont_showOnZoom.add_child(spr);
				#spr.scale.x *= randf_range(.9, 1.125);
				spr.scale.y *= randf_range(.9, 1.125);
				spr.rotation += randf_range(-.125, .125);
				spr.name = "Tree";
				
			Map_Data.Marking.LIGHTHOUSE:
				#s_array.append(null);
				spr = World.Create_Sprite(0, 11, 1, _glyphs);
				_cont_hideOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				# Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = spr.position;
				#spr.add_child(lamp);
				#isLighthouse = true;
				
			Map_Data.Marking.SHELL:
				spr = World.Create_Sprite(6, 9, 1, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale = spr.scale / 4 * 3;
			
			Map_Data.Marking.MESSAGE_BOTTLE:
				spr = World.Create_Sprite(14, 8, 1, _glyphs);
				_cont_alwaysShow.add_child(spr);
				spr.add_child(Drift.new());
				spr.rotation_degrees = randf_range(15, 45);
				
			Map_Data.Marking.SMALL_FISH:
				spr = World.Create_Sprite(0, 7);
				_cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 10.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.BIG_FISH:
				spr = World.Create_Sprite(1, 7);
				_cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 5.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.JETTY:
				spr = World.Create_Sprite(13, 12, 1, _glyphs);
				_cont_showOnZoom.add_child(spr);
				
			Map_Data.Marking.TREASURE:
				spr = World.Create_Sprite(9, 8);
				_cont_treasures.add_child(spr);
				#spr.modulate = Color.BLACK;
				spr.material = ShaderMaterial.new();
				spr.material.shader = _fadeInOut;
			
			Map_Data.Marking.TEMPLE:
				spr = World.Create_Sprite(13, 11, 1, _glyphs);
				#spr = World.Create_Sprite(10, 0);
				_cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.ORANGE;
			
			Map_Data.Marking.GOLD:
				s_array.append(null);
			
			Map_Data.Marking.HOBBIT_HOUSE:
				spr = World.Create_Sprite(5, 7);
				_cont_hideOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
			
			Map_Data.Marking.BOAT:
				spr = World.Create_Sprite(randi_range(8, 10), 7);
				_cont_alwaysShow.add_child(spr);
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
			s_array.append(spr);
			
		# Set Next marking Position
		
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
			
	if debug: print_debug("_MarkingSprites_From_MarkingData, Markings: ", s_array.size());
	return s_array;
