class_name Map_Generator extends Node2D

# Resources
const _spriteSheet:Texture2D = preload("res://Sprites/sparks_in_the_dark.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
const _fadeInOut:Shader = preload("res://Shaders/fadeInOut.gdshader");
const _wiggle:Shader = preload("res://Shaders/wiggle.gdshader");
const _goodSeeds:Array[int] = [
	3184197067,
	3043322721,
	3879980289,
	3302025460,
	3869609850,
	3622769036,
	3726595959, # Three Brothers
	278936286,
	462604253, # Broken Bridge
	1504345747, # Jurassic
	1852288905, # The Argument
	];
#const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

# World
#const World.CellSize:int = 16;
#const World.Spr_Reg_Size:float = 256;
#var _mapWidth:float;

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

var _terrain_data:Array[Map_Data.Terrain];
var _marking_data:Array[Map_Data.Marking];

# Sprite2D Arrays to quickly grab a Sprite2D by its Index
var _sprite_array_Terrain:Array[Sprite2D];
var _sprite_array_Marking:Array[Sprite2D]; # Markings / NULL
var _sprite_array_Detail:Array[Sprite2D]; # Details / NULL

# Noise Data
@export var _noiseTex:TextureRect;

# Sprite2D Containers
@onready var _cont_terrainSprites:Node2D = $terrain;
@onready var _cont_showOnZoom:Node2D = $show_on_zoom;
@onready var _cont_hideOnZoom:Node2D = $hide_on_zoom;
@onready var _cont_alwaysShow:Node2D = $always_show;
@onready var _cont_treasures:CanvasLayer = $treasures;

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
		print("map_generator, Latest Seed: ", newSeed);
		_Generate_Map(newSeed);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Generate_Map(newSeed:int) -> void:
	
	_noiseTex.texture.noise.seed = newSeed;
	await _noiseTex.texture.changed;
	var noiseData:PackedByteArray = _noiseTex.get_texture().get_image().get_data();
	
	World.Set_MapWidth(_noiseTex.get_texture().get_size().x, self.get_path());
	
	_terrain_data = Map_Data.Derive_TerrainData_From_NoiseData(
		_mountain, _highland, _ground, _coast, _shallows, _sea, _depths, 
		noiseData);
		
	_marking_data = Map_Data.Derive_MarkingData_From_TerrainData(_terrain_data);
	
	# Final Data to Use
	
	_terrain_data = Map_Data.Amend_TerrainData_Using_MarkingData(_terrain_data, _marking_data);
	_marking_data = Map_Data.Amend_MarkingData(_marking_data);
	_terrain_data = Map_Data.Amend_TerrainData(_terrain_data);
	
	#print("Terrain Count: ", _terrain_data.size());
	#print("Marking Count: ", _marking_data.size());
	
	# Create Sprite2Ds
	_sprite_array_Terrain = _TerrainSprites_From_TerrainData(_terrain_data);
	_sprite_array_Marking = _MarkingSprites_From_MarkingData(_marking_data);
	_sprite_array_Detail = _DetailSprites_From_MarkingData(_marking_data);
	#print("Terrain Sprite Array: ", _sprite_array_Terrain.size());
	#print("Marking Sprite Array: ", _sprite_array_Marking.size());
	#print("Detail Sprite Array: ", _sprite_array_Detail.size());
	
	World.Signal_Initial_MapGen_Complete(self.get_path());


func _Clear() -> void:
	
	# Delete Sprite2Ds
	for c in _cont_terrainSprites.get_children(): c.queue_free();
	for c in _cont_showOnZoom.get_children(): c.queue_free();
	for c in _cont_hideOnZoom.get_children(): c.queue_free();
	for c in _cont_alwaysShow.get_children(): c.queue_free();
	for c in _cont_treasures.get_children(): c.queue_free();
	# Delete Sprite2D References
	_sprite_array_Terrain = [];
	_sprite_array_Marking = [];
	_sprite_array_Detail = [];
	
	#_messageBottle_spawned = false;


# Functions: Create Sprites ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _TerrainSprites_From_TerrainData(terrainData:Array[Map_Data.Terrain]) -> Array[Sprite2D]:
	
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
		if currX >= World.MapWidth():
			currX = 0;
			currY += 1;
		
		s_array.append(spr);
	
	if _debug: print_debug("_TerrainSprites_From_TerrainData, Terrain: ", s_array.size());
	return s_array;


func _MarkingSprites_From_MarkingData(markingData:Array[Map_Data.Marking]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m in markingData:
		
		var spr:Sprite2D = null;
		
		match m:
		
			Map_Data.Marking.	HOUSE:
				spr = _Create_Sprite(6, 7, _spriteSheet);
				_cont_hideOnZoom.add_child(spr);
				
			#Map_Data.Marking.TENT:
				#spr = _Create_Sprite(4, 9, _glyphs);
				#_cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.BLACK;
				
			Map_Data.Marking.PEAK:
				spr = _Create_Sprite(3, 6, _spriteSheet);
				_cont_alwaysShow.add_child(spr);
				spr.scale *= randf_range(1, 1.5);
				
			Map_Data.Marking.HILL:
				spr = _Create_Sprite(5, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.BLACK;
				#spr.scale /= 1.5;
				
			Map_Data.Marking.TREE:
				spr = _Create_Sprite(7, 6, _spriteSheet);
				_cont_alwaysShow.add_child(spr);
				#spr.modulate = Color.BLACK;
				
			Map_Data.Marking.LIGHTHOUSE:
				spr = _Create_Sprite(0, 11, _glyphs);
				_cont_hideOnZoom.add_child(spr);
				# Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = spr.position;
				#spr.add_child(lamp);
				#isLighthouse = true;
				
			Map_Data.Marking.SHELL:
				spr = _Create_Sprite(6, 9, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale = spr.scale / 4 * 3;
			
			Map_Data.Marking.MESSAGE_BOTTLE:
				spr = _Create_Sprite(14, 8, _glyphs);
				_cont_treasures.add_child(spr);
				spr.add_child(Drift.new());
				#spr.texture = _glyphs;
				#spr.region_enabled = true;
				#spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size);
				#spr.region_rect.position = Vector2(14, 8) * World.Spr_Reg_Size;
				#spr.scale /= World.CellSize;
				#spr.modulate = Color.BLACK;
				spr.rotation_degrees = randf_range(15, 45);
				#spr.scale = spr.scale / 4 * 3;
				
			Map_Data.Marking.SMALL_FISH:
				spr = _Create_Sprite(0, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 10.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.BIG_FISH:
				spr = _Create_Sprite(1, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _wiggle;
				spr.material.set_shader_parameter("amplitude", randf_range(1.0, 5.0));
				spr.material.set_shader_parameter("prog", randf_range(0.0, 10.0));
				
			Map_Data.Marking.JETTY:
				spr = _Create_Sprite(13, 12, _glyphs);
				_cont_showOnZoom.add_child(spr);
				
			Map_Data.Marking.TREASURE:
				spr = _Create_Sprite(9, 8, _spriteSheet);
				_cont_treasures.add_child(spr);
				spr.material = ShaderMaterial.new();
				spr.material.shader = _fadeInOut;
				
			#Map_Data.Marking.WHALE:
				#spr = _Create_Sprite(2, 5, _glyphs);
				#_cont_showOnZoom.add_child(spr);
			
			#Map_Data.Marking.HOT_AIR_BALLOON:
				#spr = _Create_Sprite(10, 5, _spriteSheet);
				#_cont_treasures.add_child(spr);
			
			Map_Data.Marking.SEAGRASS:
				spr = _Create_Sprite(0, 5, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				spr.rotation_degrees = 90;
				spr.modulate.a = randf_range(.125, .25);
			
			Map_Data.Marking.TEMPLE:
				spr = _Create_Sprite(13, 11, _glyphs);
				#spr = _Create_Sprite(10, 0, _spriteSheet);
				_cont_alwaysShow.add_child(spr);
				#spr.modulate = Color.ORANGE;
			
			Map_Data.Marking.GOLD:
				s_array.append(null);
			
			Map_Data.Marking.Null:
				s_array.append(null);
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(m));
			
		# Position Marking
		
		if spr:
			spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			#marking.position += Vector2.ONE * randf_range(-.4, .4);
			s_array.append(spr);
			
		# Set Next marking Position
		
		currX += 1;
		if currX >= World.MapWidth():
			currX = 0;
			currY += 1;
			
	if _debug: print_debug("_MarkingSprites_From_MarkingData, Markings: ", s_array.size());
	return s_array;


func _DetailSprites_From_MarkingData(markingData:Array[Map_Data.Marking]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m in markingData:
		
		var spr:Sprite2D = null;
		
		match m:
		
			Map_Data.Marking.	HOUSE:
				
				spr = _Create_Sprite(randi_range(2, 4), 14, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position.y = currY * World.CellSize - randf_range(0, World.CellSize / 1.5);
				spr.scale *= randf_range(1, 1.125);
				spr.scale /= 1.5;
				spr.rotation += randf_range(-.125, .125);
				
			#Map_Data.Marking.TENT:
				#pass;
			Map_Data.Marking.PEAK:
				pass;
			Map_Data.Marking.HILL:
				pass;
				
			Map_Data.Marking.TREE:
				pass;
				
				#spr = _Create_Sprite(8, 6, _spriteSheet);
				#_cont_showOnZoom.add_child(spr);
				#
				#spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				## Randomise Transform
				#spr.position += Vector2.ONE * randf_range(-.4, .4);
				#spr.scale += Vector2.ONE * randf_range(-.01, .02);
				#spr.offset.y -= World.CellSize * 4;
				
			Map_Data.Marking.LIGHTHOUSE:
				
				#spr = _Create_Sprite(14, 5, _spriteSheet);
				#spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size * 2);
				#spr.offset.y -= World.Spr_Reg_Size;
				
				spr = _Create_Sprite(6, 12, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				
				# Adjust Sprite2D
				spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size * 3);
				spr.offset.y -= World.Spr_Reg_Size + World.Spr_Reg_Size / 2;
				spr.scale /= 2;
				
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
			Map_Data.Marking.SEAGRASS:
				pass;
			Map_Data.Marking.TEMPLE:
				pass;
				
			Map_Data.Marking.GOLD:
				
				spr = _Create_Sprite(2, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.modulate.a = _alphaThresh * 1 + randf_range(-0.0625, .0625);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				#spr.position -= Vector2.ONE * randf_range(0, World.CellSize / 1.5);
				spr.scale *= randf_range(-1, 1.125);
				spr.rotation += randf_range(-.125, .125);
			
			Map_Data.Marking.MESSAGE_BOTTLE:
				pass;
				
			Map_Data.Marking.Null:
				pass;
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(m));
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= World.MapWidth():
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


func _Configure_TerrainSprite_LandAndSea(spr:Sprite2D, terrainType:Map_Data.Terrain) -> void:
	
	match terrainType:
		Map_Data.Terrain.MOUNTAIN:
			spr.region_rect.position.x = World.Spr_Reg_Size * 2;
		Map_Data.Terrain.HIGHLAND:
			spr.region_rect.position.x = World.Spr_Reg_Size * 3;
			#spr.modulate.r -= .25;
			#spr.modulate.b -= .25;
			#spr.modulate.s += 1;
			spr.modulate.v -= .2;
		Map_Data.Terrain.GROUND:
			spr.region_rect.position.x = World.Spr_Reg_Size * 3;
			#spr.modulate.v -= .2;
		Map_Data.Terrain.COAST:
			spr.region_rect.position.x = World.Spr_Reg_Size * 4;
		Map_Data.Terrain.SHALLOWS:
			spr.modulate.a = _alphaThresh * 3;
		Map_Data.Terrain.SEA:
			spr.modulate.a = _alphaThresh * 1.75 - randf_range(0, .125);
			#spr.modulate.g -= .25;
		Map_Data.Terrain.DEPTHS:
			spr.modulate.a = _alphaThresh * .7 - randf_range(0, .0625);
		Map_Data.Terrain.ABYSS:
			spr.modulate.a = _alphaThresh * 0;
		# Specials
		Map_Data.Terrain.SEA_GREEN:
			spr.modulate.a = _alphaThresh * 1.6 - randf_range(0, .125);
			var rand:float = randf_range(.125, .25);
			spr.modulate.b -= rand;
		Map_Data.Terrain.TEMPLE_BROWN:
			#spr.region_rect.position.x = World.Spr_Reg_Size * 5;
			spr.region_rect.position.x = World.Spr_Reg_Size * 9;
		Map_Data.Terrain.DEBUG_HOLE:
			spr.region_rect.position.x = World.Spr_Reg_Size * 10;
			
		Map_Data.Terrain.Null:
			spr.region_rect.position.x = World.Spr_Reg_Size * 8;
			
		_:
			print_debug("\nTerrain Data contains Invalid Data");


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func ChangeTerrain(v2_array:Array[Vector2], terrainType:Map_Data.Terrain, callerPath:String) -> void:
	if _debug: print_debug("ChangeTerrain, called by: ", callerPath);
	_ChangeTerrain(v2_array, terrainType);

func _ChangeTerrain(v2_array:Array[Vector2], terrainType:Map_Data.Terrain) -> void:
	for v2 in v2_array:
		var spr:Sprite2D = _sprite_array_Terrain[(World.MapWidth()) * (v2.y / World.CellSize) + (v2.x / World.CellSize)];
		_Configure_TerrainSprite_LandAndSea(spr, terrainType);


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


#func MapGenerator_Get_CellSize(callerPath:String) -> float:
	#if _debug: print_debug("MapGenerator_Get_CellSize, Called by:", callerPath);
	#return World.CellSize;


func MapGenerator_Get_TerrainSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print_debug("MapGenerator_Get_TerrainSprite, called by: ", callerPath);
	var index:int = (coord.x + World.MapWidth() * coord.y) / World.CellSize;
	return _sprite_array_Terrain[index];
	
func MapGenerator_Get_MarkingSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print_debug("MapGenerator_Get_MarkingSprite, called by: ", callerPath);
	var index:int = (coord.x + World.MapWidth() * coord.y) / World.CellSize;
	return _sprite_array_Marking[index];
	
func MapGenerator_Get_DetailSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print_debug("MapGenerator_Get_DetailSprite, called by: ", callerPath);
	var index:int = (coord.x + World.MapWidth() * coord.y) / World.CellSize;
	return _sprite_array_Detail[index];


func Is_Land(coord:Vector2, callerPath:String) -> bool:
	if _debug: print_debug("Is_Land, called by: ", callerPath);
	var index:int = (coord.x + World.MapWidth() * coord.y) / World.CellSize;
	
	match _terrain_data[index]:
		Map_Data.Terrain.SHALLOWS:
			return false;
		Map_Data.Terrain.SEA:
			return false;
		Map_Data.Terrain.DEPTHS:
			return false;
		Map_Data.Terrain.ABYSS:
			return false;
		Map_Data.Terrain.SEA_GREEN:
			return false;
	
	return true;
