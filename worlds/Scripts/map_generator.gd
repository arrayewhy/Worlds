extends Node2D

enum Terrain {
	Null,
	MOUNTAIN,
	HIGHLAND,
	GROUND,
	COAST,
	SHALLOWS,
	SEA,
	DEPTHS,
	ABYSS,
	# Specials
	SEA_GREEN,
	TEMPLE_RED,
	}

enum Marking { 
	Null,
	HOUSE,
	#TENT,
	PEAK,
	HILLS,
	TREE,
	LIGHTHOUSE,
	SHELL,
	SMALL_FISH,
	BIG_FISH,
	JETTY,
	TREASURE,
	WHALE,
	#HOT_AIR_BALLOON,
	OARFISH,
	SEAGRASS,
	TEMPLE,
	GOLD,
	MESSAGE_BOTTLE,
	}

# Resources
const _spriteSheet:Texture2D = preload("res://Sprites/sparks_in_the_dark.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
const _fadeInOut:Shader = preload("res://Shaders/fadeInOut.gdshader");
const _wiggle:Shader = preload("res://Shaders/wiggle.gdshader");
const _goodSeeds:Array[int] = [ 3184197067, 3043322721, 3879980289, 3302025460 ];
#const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

# World
#const World.CellSize:int = 16;
#const World.Spr_Reg_Size:float = 256;
var _mapWidth:float;

# Thresholds
@export var _mountain:float = 230;
@export var _highland:float = 210;
@export var _ground:float = 190;
@export var _coast:float = 180;
@export var _shallows:float = 160;
@export var _sea:float = 130;
@export var _depths:float = 80;
# Water Depth Alpha
const _waterDepth:float = 4.0;
const _alphaThresh:float = 1.0 / _waterDepth;

# Sprite2D Arrays to quickly grab a Sprite2D by its Index
var _terrain_sprite_array:Array[Sprite2D];
var _marking_sprite_array:Array[Sprite2D]; # Markings / NULL
var _detail_sprite_array:Array[Sprite2D]; # Details / NULL

# Noise Data
@export var _noiseTex:TextureRect;

# Sprite2D Containers
@onready var _cont_terrainSprites:Node2D = $Containers/Terrain;
@onready var _cont_showOnZoom:Node2D = $Containers/show_on_zoom;
@onready var _cont_hideOnZoom:Node2D = $Containers/hide_on_zoom;
@onready var _cont_alwaysShow:Node2D = $Containers/always_show;
@onready var _cont_treasures:CanvasLayer = $Treasures;

@export_group("#DEBUG")
@export var _debug:bool;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	# Make sure Zoom Objects start off Invisible
	_cont_showOnZoom.modulate.a = 0;
	
	_Generate_Map(3);


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		_Clear();
		var newSeed:int = randi();
		print_debug("Latest Seed: ", newSeed);
		_Generate_Map(newSeed);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Generate_Map(newSeed:int) -> void:

	_noiseTex.texture.noise.seed = newSeed;
	await _noiseTex.texture.changed;
	var noiseData:PackedByteArray = _noiseTex.get_texture().get_image().get_data();
	
	# Terrain & Marking Data are NOT permanent Variables
	# because they are NOT expected to be used Elsewhere.
	var terrainData:Array[Terrain] = _TerrainData_From_NoiseData(noiseData);
	var markingData:Array[Marking] = _MarkingData_From_TerrainData(terrainData);

	# Final Data to Use
	
	terrainData = _ManipulateData_TerrainFromMarking(terrainData, markingData);

	_mapWidth = _noiseTex.get_texture().get_size().x;
	
	# Create Sprite2Ds
	_terrain_sprite_array = _TerrainSprites_From_TerrainData(terrainData);
	_marking_sprite_array = _MarkingSprites_From_MarkingData(markingData);
	_detail_sprite_array = _DetailSprites_From_MarkingData(markingData);


func _Clear() -> void:
	# Delete Sprite2Ds
	for c in _cont_terrainSprites.get_children(): c.queue_free();
	for c in _cont_showOnZoom.get_children(): c.queue_free();
	for c in _cont_hideOnZoom.get_children(): c.queue_free();
	for c in _cont_alwaysShow.get_children(): c.queue_free();
	for c in _cont_treasures.get_children(): c.queue_free();
	# Delete Sprite2D References
	_terrain_sprite_array = [];
	_marking_sprite_array = [];
	_detail_sprite_array = [];


# Functions: Generate Data ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _TerrainData_From_NoiseData(noiseData:Array) -> Array[Terrain]:
	
	var t:Array[Terrain];
	
	for d in noiseData:
		if d >= _mountain:
			t.append(Terrain.MOUNTAIN);
			continue;
		elif d >= _highland && d < _mountain:
			t.append(Terrain.HIGHLAND);
			continue;
		elif d >= _ground && d < _highland:
			t.append(Terrain.GROUND);
			continue;
		elif d >= _coast && d < _ground:
			t.append(Terrain.COAST);
			continue;
		elif d >= _shallows && d < _coast:
			t.append(Terrain.SHALLOWS);
			continue;
		elif d >= _sea && d < _shallows:
			t.append(Terrain.SEA);
			continue;
		elif d >= _depths && d < _sea:
			
			t.append(Terrain.DEPTHS);
			continue;
			
		elif d < _depths:
			t.append(Terrain.ABYSS)
			continue;
	
	return t;


func _MarkingData_From_TerrainData(terrainData:Array[Terrain]) -> Array[Marking]:
	
	var m:Array[Marking];
	
	for t in terrainData:
		
		match t:
			
			Terrain.MOUNTAIN:
				if randi_range(0, 1000) > 999:
					m.append(Marking.HOUSE);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				elif randi_range(0, 1000) > 200:
					m.append(Marking.PEAK);
				#elif randi_range(0, 1000) > 990:
					#m.append(Marking.HOT_AIR_BALLOON);
				else:
					m.append(Marking.HILLS);
				continue;
			
			Terrain.HIGHLAND:
				if randi_range(0, 1000) > 500:
					m.append(Marking.HILLS);
				elif randi_range(0, 1000) > 200:
					m.append(Marking.TREE);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.GROUND:
				if randi_range(0, 1000) > 600:
					m.append(Marking.TREE);
				elif randi_range(0, 1000) > 980:
					m.append(Marking.HOUSE);
				elif randi_range(0, 1000) > 998:
					m.append(Marking.TEMPLE);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.COAST:
				if randi_range(0, 1000) > 990:
					m.append(Marking.LIGHTHOUSE);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.SHELL);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.SHALLOWS:
				if randi_range(0, 1000) > 960:
					m.append(Marking.SMALL_FISH);
				elif randi_range(0, 1000) > 995:
					m.append(Marking.JETTY);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.SEA:
				if randi_range(0, 1000) > 900:
					m.append(Marking.SEAGRASS);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.BIG_FISH);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.GOLD);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.DEPTHS:
				if randi_range(0, 1000) > 980:
					m.append(Marking.GOLD);
				elif randi_range(0, 1000) > 595:
					m.append(Marking.MESSAGE_BOTTLE);
				else:
					m.append(Marking.Null);
				continue;
			
			Terrain.ABYSS:
				if randf_range(0, 1000) > 997:
					m.append(Marking.TREASURE);
				elif randf_range(0, 1000) > 996:
					m.append(Marking.WHALE);
				else:
					m.append(Marking.Null);
				continue;
				
			# Specials
			Terrain.SEA_GREEN:
				m.append(Marking.Null);
				continue;
			Terrain.TEMPLE_RED:
				m.append(Marking.Null);
				continue;
				
			_:
				print_debug("\nMarking Data contains Invalid Data");
				continue;
			
	return m;


func _ManipulateData_TerrainFromMarking(terrainData:Array[Terrain], markingData:Array[Marking]) -> Array[Terrain]:
	
	var t:Array[Terrain] = terrainData;
	
	for i in markingData.size():
		match markingData[i]:
			Marking.SEAGRASS:
				t[i] = Terrain.SEA_GREEN;
			Marking.TEMPLE:
				t[i] = Terrain.TEMPLE_RED;
				
	return t;


# Functions: Create Sprites ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _TerrainSprites_From_TerrainData(terrainData:Array[Terrain]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for t in terrainData:
		
		# Create Sprite
		var spr:Sprite2D = _Create_Sprite(0, 0, _spriteSheet);
		_cont_terrainSprites.add_child(spr);
		_Configure_TerrainSprite_LandAndSea(spr, t);
		
		# Position Terrain Sprite
		
		spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
		#spr.position += Vector2.ONE * randf_range(-.4, .4);
		spr.rotation += randf_range(-.0625, .0625);
		
		# Set Next sprite Position
		
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
		
		s_array.append(spr);
	
	if _debug: print_debug("_TerrainSprites_From_TerrainData, Terrain: ", s_array.size());
	return s_array;


func _MarkingSprites_From_MarkingData(markingData:Array[Marking]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m in markingData:
		
		var spr:Sprite2D = null;
		
		match m:
		
			Marking.	HOUSE:
				spr = _Create_Sprite(6, 7, _spriteSheet);
				_cont_hideOnZoom.add_child(spr);
				
			#Marking.TENT:
				#spr = _Create_Sprite(4, 9, _glyphs);
				#_cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.BLACK;
				
			Marking.PEAK:
				spr = _Create_Sprite(3, 6, _spriteSheet);
				_cont_alwaysShow.add_child(spr);
				spr.scale *= randf_range(1, 1.5);
				
			Marking.HILLS:
				spr = _Create_Sprite(5, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.BLACK;
				#spr.scale /= 1.5;
				
			Marking.TREE:
				spr = _Create_Sprite(7, 6, _spriteSheet);
				_cont_hideOnZoom.add_child(spr);
				
			Marking.LIGHTHOUSE:
				spr = _Create_Sprite(0, 11, _glyphs);
				_cont_hideOnZoom.add_child(spr);
				# Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = spr.position;
				#spr.add_child(lamp);
				#isLighthouse = true;
				
			Marking.SHELL:
				spr = _Create_Sprite(6, 9, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale = spr.scale / 4 * 3;
			
			Marking.MESSAGE_BOTTLE:
				spr = _Create_Sprite(14, 8, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.add_child(Drift.new());
				#spr.texture = _glyphs;
				#spr.region_enabled = true;
				#spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size);
				#spr.region_rect.position = Vector2(14, 8) * World.Spr_Reg_Size;
				#spr.scale /= World.CellSize;
				#spr.modulate = Color.BLACK;
				spr.rotation_degrees = randf_range(15, 45);
				#spr.scale = spr.scale / 4 * 3;
				
			Marking.SMALL_FISH:
				spr = _Create_Sprite(0, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(5.0, 20.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Marking.BIG_FISH:
				spr = _Create_Sprite(1, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(5.0, 10.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Marking.JETTY:
				spr = _Create_Sprite(13, 12, _glyphs);
				_cont_showOnZoom.add_child(spr);
				
			Marking.TREASURE:
				spr = _Create_Sprite(9, 8, _spriteSheet);
				_cont_treasures.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _fadeInOut;
				
			Marking.WHALE:
				spr = _Create_Sprite(2, 5, _glyphs);
				_cont_showOnZoom.add_child(spr);
			
			#Marking.HOT_AIR_BALLOON:
				#spr = _Create_Sprite(10, 5, _spriteSheet);
				#_cont_treasures.add_child(spr);
			
			Marking.SEAGRASS:
				spr = _Create_Sprite(0, 5, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				spr.rotation_degrees = 90;
				spr.modulate.a = randf_range(.125, .25);
			
			Marking.TEMPLE:
				spr = _Create_Sprite(13, 11, _glyphs);
				#spr = _Create_Sprite(10, 0, _spriteSheet);
				_cont_alwaysShow.add_child(spr);
				#spr.modulate = Color.ORANGE;
			
			Marking.GOLD:
				pass;
			
			Marking.Null:
				s_array.append(null);
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Marking.find_key(m));
			
		# Position Marking
		
		if spr:
			spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			#marking.position += Vector2.ONE * randf_range(-.4, .4);
			s_array.append(spr);
			
		# Set Next marking Position
		
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
			
	if _debug: print_debug("_MarkingSprites_From_MarkingData, Markings: ", s_array.size());
	return s_array;


func _DetailSprites_From_MarkingData(markingData:Array[Marking]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m in markingData:
		
		var spr:Sprite2D = null;
		
		match m:
		
			Marking.	HOUSE:
				
				spr = _Create_Sprite(randi_range(2, 4), 14, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position.y = currY * World.CellSize - randf_range(0, World.CellSize / 1.5);
				spr.scale *= randf_range(1, 1.125);
				spr.rotation += randf_range(-.125, .125);
				
			#Marking.TENT:
				#pass;
			Marking.PEAK:
				pass;
			Marking.HILLS:
				pass;
				
			Marking.TREE:
				
				spr = _Create_Sprite(8, 6, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position += Vector2.ONE * randf_range(-.4, .4);
				spr.scale += Vector2.ONE * randf_range(-.01, .02);
				spr.offset.y -= World.CellSize * 4;
				
			Marking.LIGHTHOUSE:
				
				spr = _Create_Sprite(6, 12, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				
				# Adjust Sprite2D
				spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size * 3);
				spr.offset.y -= World.Spr_Reg_Size + World.Spr_Reg_Size / 2;
				
			Marking.SHELL:
				pass;
			Marking.SMALL_FISH:
				pass;
			Marking.BIG_FISH:
				pass;
			Marking.JETTY:
				pass;
			Marking.TREASURE:
				pass;
			Marking.WHALE:
				pass;
			Marking.SEAGRASS:
				pass;
			Marking.TEMPLE:
				pass;
				
			Marking.GOLD:
				
				spr = _Create_Sprite(2, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.modulate.a = _alphaThresh * 1 + randf_range(-0.0625, .0625);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				#spr.position -= Vector2.ONE * randf_range(0, World.CellSize / 1.5);
				spr.scale *= randf_range(-1, 1.125);
				spr.rotation += randf_range(-.125, .125);
			
			Marking.MESSAGE_BOTTLE:
				pass;
				
			Marking.Null:
				pass;
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Marking.find_key(m));
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
			
	if _debug: print_debug("_DetailSprites_From_MarkingData, Details: ", s_array.size());
	return s_array;


func Create_Sprite(regPosX:float, regPosY:float, callerPath:String) -> Sprite2D:
	if _debug: print_debug("Create_Sprite, called by: ", callerPath);
	return _Create_Sprite(regPosX, regPosY, _spriteSheet);
	
func _Create_Sprite(regPosX:float, regPosY:float, tex:Texture2D) -> Sprite2D:
	var spr:Sprite2D = Sprite2D.new();
	spr.texture = tex;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size);
	spr.region_rect.position = Vector2(regPosX, regPosY) * World.Spr_Reg_Size;
	spr.scale /= World.CellSize;
	return spr;


func _Configure_TerrainSprite_LandAndSea(spr:Sprite2D, terrainType:Terrain) -> void:
	
	match terrainType:
		Terrain.MOUNTAIN:
			spr.region_rect.position.x = World.Spr_Reg_Size * 2;
		Terrain.HIGHLAND:
			spr.region_rect.position.x = World.Spr_Reg_Size * 3;
			#spr.modulate.r -= .25;
			#spr.modulate.b -= .25;
			#spr.modulate.s += 1;
			spr.modulate.v -= .2;
		Terrain.GROUND:
			spr.region_rect.position.x = World.Spr_Reg_Size * 3;
			#spr.modulate.v -= .2;
		Terrain.COAST:
			spr.region_rect.position.x = World.Spr_Reg_Size * 4;
		Terrain.SHALLOWS:
			spr.modulate.a = _alphaThresh * 3;
		Terrain.SEA:
			spr.modulate.a = _alphaThresh * 1.75 - randf_range(0, .125);
			#spr.modulate.g -= .25;
		Terrain.DEPTHS:
			spr.modulate.a = _alphaThresh * .7 - randf_range(0, .0625);
		Terrain.ABYSS:
			spr.modulate.a = _alphaThresh * 0;
		# Specials
		Terrain.SEA_GREEN:
			spr.modulate.a = _alphaThresh * 1.6 - randf_range(0, .125);
			var rand:float = randf_range(.125, .25);
			spr.modulate.b -= rand;
		Terrain.TEMPLE_RED:
			#spr.region_rect.position.x = World.Spr_Reg_Size * 5;
			spr.region_rect.position.x = World.Spr_Reg_Size * 10;
			
		_:
			print_debug("\nTerrain Data contains Invalid Data");


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func ChangeTerrain(v2_array:Array[Vector2], terrainType:Terrain, callerPath:String) -> void:
	if _debug: print_debug("ChangeTerrain, called by: ", callerPath);
	_ChangeTerrain(v2_array, terrainType);

func _ChangeTerrain(v2_array:Array[Vector2], terrainType:Terrain) -> void:
	for v2 in v2_array:
		var spr:Sprite2D = _terrain_sprite_array[(_mapWidth) * (v2.y / World.CellSize) + (v2.x / World.CellSize)];
		_Configure_TerrainSprite_LandAndSea(spr, terrainType);


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func MapGenerator_Get_CellSize(callerPath:String) -> float:
	if _debug: print_debug("MapGenerator_Get_CellSize, Called by:", callerPath);
	return World.CellSize;


func MapGenerator_Get_TerrainSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print_debug("MapGenerator_Get_TerrainSprite, called by: ", callerPath);
	var index:int = (coord.x + _mapWidth * coord.y) / World.CellSize;
	return _terrain_sprite_array[index];


func MapGenerator_Get_MarkingSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print_debug("MapGenerator_Get_MarkingSprite, called by: ", callerPath);
	var index:int = (coord.x + _mapWidth * coord.y) / World.CellSize;
	return _marking_sprite_array[index];


func MapGenerator_Get_DetailSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print_debug("MapGenerator_Get_DetailSprite, called by: ", callerPath);
	var index:int = (coord.x + _mapWidth * coord.y) / World.CellSize;
	return _detail_sprite_array[index];
