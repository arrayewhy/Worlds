extends Node2D

# Resources
const _spriteSheet:Texture2D = preload("res://Sprites/Clack_Map_SpriteSheet_2048.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
#const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

# World
const _cellSize:int = 16;
const _sprRegSize:float = 256;
var _mapWidth:float;

# Terrain
enum Terrain {
	Null,
	ABYSS,
	DEPTHS,
	SEA,
	SHALLOWS,
	COAST,
	GROUND,
	HIGHLAND,
	MOUNTAIN
	}
# Thresholds
@export var _mountain:float = 230;
@export var _highland:float = 220;
@export var _ground:float = 180;
@export var _coast:float = 175;
@export var _shallows:float = 160;
@export var _sea:float = 130;
@export var _depths:float = 80;
# Water Depth Alpha
const _waterDepth:float = 4.0;
const _alphaThresh:float = 1.0 / _waterDepth;

# Markings
enum Marking { 
	Null,
	HOUSE,
	TENT,
	PEAK,
	HILLS,
	TREE,
	LIGHTHOUSE,
	SHELL,
	SMALL_FISH,
	BIG_FISH,
	JETTY,
	TREASURE,
	WHALE
	}

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


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	# Make sure Zoom Objects start off Invisible
	_cont_showOnZoom.modulate.a = 0;
	
	_Generate_Map(3);


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		_Clear();
		_Generate_Map(randi());


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Generate_Map(newSeed:int) -> void:

	_noiseTex.texture.noise.seed = newSeed;
	await _noiseTex.texture.changed;
	var noiseData:PackedByteArray = _noiseTex.get_texture().get_image().get_data();
	
	# Terrain & Marking Data are NOT permanent Variables
	# because they are NOT expected to be used Elsewhere.
	var terrainData:Array[Terrain] = _TerrainData_From_NoiseData(noiseData);
	var markingData:Array[Marking] = _MarkingData_From_TerrainData(terrainData);

	_mapWidth = _noiseTex.get_texture().get_size().x;
	
	# Create Sprite2Ds
	_terrain_sprite_array = _TerrainSprites_From_TerrainData(terrainData);
	#print(_terrain_sprite_array.size());
	_marking_sprite_array = _MarkingSprites_From_MarkingData(markingData);
	#print(_marking_sprite_array.size());
	_detail_sprite_array = _DetailSprites_From_MarkingData(markingData);
	#print(_detail_sprite_array.size());


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
				elif randi_range(0, 1000) > 995:
					m.append(Marking.TENT);
				elif randi_range(0, 1000) > 200:
					m.append(Marking.PEAK);
				else:
					m.append(Marking.HILLS);
				continue;
			
			Terrain.HIGHLAND:
				if randi_range(0, 1000) > 900:
					m.append(Marking.HILLS);
				elif randi_range(0, 1000) > 995:
					m.append(Marking.TENT);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.GROUND:
				if randi_range(0, 1000) > 600:
					m.append(Marking.TREE);
				elif randi_range(0, 1000) > 980:
					m.append(Marking.HOUSE);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.COAST:
				if randi_range(0, 1000) > 990:
					m.append(Marking.LIGHTHOUSE);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.SHELL);
				elif randi_range(0, 1000) > 995:
					m.append(Marking.TENT);
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
				if randi_range(0, 1000) > 990:
					m.append(Marking.BIG_FISH);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.DEPTHS:
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
				
			_:
				print_debug("Marking Data contains Invalid Data");
				continue;
			
	return m;


# Functions: Create Sprites ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _TerrainSprites_From_TerrainData(terrainData:Array[Terrain]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for t in terrainData:
		
		# Create Sprite
		var spr:Sprite2D = _Create_Sprite(0, 0, _spriteSheet);
		_cont_terrainSprites.add_child(spr);
		
		match t:
			Terrain.MOUNTAIN:
				spr.region_rect.position.x = _sprRegSize * 2;
			Terrain.HIGHLAND:
				spr.region_rect.position.x = _sprRegSize * 3;
			Terrain.GROUND:
				spr.region_rect.position.x = _sprRegSize * 3;
			Terrain.COAST:
				spr.region_rect.position.x = _sprRegSize * 4;
			Terrain.SHALLOWS:
				spr.modulate.a = _alphaThresh * 5;
			Terrain.SEA:
				spr.modulate.a = _alphaThresh * 1.6 - randf_range(0, .125);
			Terrain.DEPTHS:
				spr.modulate.a = _alphaThresh * .5 - randf_range(0, .0625);
			Terrain.ABYSS:
				spr.modulate.a = _alphaThresh * 0;
			_:
				print_debug("Terrain Data contains Invalid Data");
		
		# Position Terrain Sprite
		
		spr.position = Vector2(currX * _cellSize, currY * _cellSize);
		#spr.position += Vector2.ONE * randf_range(-.4, .4);
		spr.rotation += randf_range(-.0625, .0625);
		
		# Set Next sprite Position
		
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
		
		s_array.append(spr);
	
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
				
			Marking.TENT:
				spr = _Create_Sprite(4, 9, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				
			Marking.PEAK:
				spr = _Create_Sprite(3, 6, _spriteSheet);
				_cont_alwaysShow.add_child(spr);
				spr.scale *= randf_range(1, 1.5);
				
			Marking.HILLS:
				spr = _Create_Sprite(9, 1, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.modulate = Color.BLACK;
				spr.scale /= 1.5;
				
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
				
			Marking.SMALL_FISH:
				spr = _Create_Sprite(0, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
			Marking.BIG_FISH:
				spr = _Create_Sprite(1, 7, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
			Marking.JETTY:
				spr = _Create_Sprite(13, 12, _glyphs);
				_cont_showOnZoom.add_child(spr);
				
			Marking.TREASURE:
				spr = _Create_Sprite(9, 8, _spriteSheet);
				_cont_treasures.add_child(spr);
				var flicker:Treasure_Flicker = Treasure_Flicker.new();
				flicker.Set_CellSize(_cellSize);
				spr.add_child(flicker);
				
			Marking.WHALE:
				spr = _Create_Sprite(2, 5, _glyphs);
				_cont_showOnZoom.add_child(spr);
			
			Marking.Null:
				s_array.append(null);
			
			_:
				print_debug("Marking Data contains Invalid Data");
			
		# Position Marking
		
		if spr:
			spr.position = Vector2(currX * _cellSize, currY * _cellSize);
			#marking.position += Vector2.ONE * randf_range(-.4, .4);
			s_array.append(spr);
			
		# Set Next marking Position
		
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
			
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
				
				spr.position = Vector2(currX * _cellSize, currY * _cellSize);
				# Randomise Transform
				spr.position.y = currY * _cellSize - randf_range(0, _cellSize / 1.5);
				spr.scale *= randf_range(1, 1.125);
				spr.rotation += randf_range(-.125, .125);
				
			Marking.TENT:
				pass;
				
			Marking.PEAK:
				pass;
				
			Marking.HILLS:
				pass;
				
			Marking.TREE:
				
				spr = _Create_Sprite(8, 6, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * _cellSize, currY * _cellSize);
				# Randomise Transform
				spr.position += Vector2.ONE * randf_range(-.4, .4);
				spr.scale += Vector2.ONE * randf_range(-.01, .02);
				spr.offset.y -= _cellSize * 4;
				
			Marking.LIGHTHOUSE:
				
				spr = _Create_Sprite(6, 12, _spriteSheet);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * _cellSize, currY * _cellSize);
				
				# Adjust Sprite2D
				spr.region_rect.size = Vector2(256, 256 * 3);
				spr.offset.y -= _sprRegSize + _sprRegSize / 2;
				
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
				
			Marking.Null:
				pass;
			
			_:
				print_debug("Marking Data contains Invalid Data");
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
			
	return s_array;


func _Create_Sprite(regPosX:float, regPosY:float, tex:Texture2D) -> Sprite2D:
	var spr:Sprite2D = Sprite2D.new();
	spr.texture = tex;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(_sprRegSize, _sprRegSize);
	spr.region_rect.position = Vector2(regPosX, regPosY) * _sprRegSize;
	spr.scale /= _cellSize;
	return spr;


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func MapGenerator_Get_CellSize(callerPath:String) -> float:
	print("MapGenerator_Get_CellSize, Called by:", callerPath);
	return _cellSize;
