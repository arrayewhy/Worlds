extends Node2D

# Resources
const _spriteSheet:Texture2D = preload("res://Sprites/Clack_Map_SpriteSheet_2048.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
#const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

enum Elevation { Null, VOID, LOWEST, LOWER, LOW, MID, HIGH, HIGHER, HIGHEST }
@export var _highest:float = 230;
@export var _higher:float = 220;
@export var _high:float = 210;
@export var _mid:float = 150;
@export var _low:float = 90;
@export var _lower:float = 70;
@export var _lowest:float = 50;

const _levelCount:float = 4.0;
const _alphaThresh:float = 1.0 / _levelCount;

# World
const _cellSize:int = 16;
const _sprRegSize:float = 256;
var _mapWidth:float;

enum Cell { Null, ABYSS, DEPTHS, SEA, SHALLOWS, COAST, GROUND, HIGHLAND, MOUNTAIN }
var _cell_sprites:Array[Sprite2D]; # Cells

enum Marking { Null, HOUSE, TENT, PEAK, HILLS, TREE, LIGHTHOUSE, SHELL, SMALL_FISH, BIG_FISH, JETTY, TREASURE, WHALE }
var _marking_sprites:Array[Sprite2D]; # Markings / Treasure / NULL

var _detail_sprites:Array[Sprite2D]; # Details / NULL

@export var _noiseTex:TextureRect;

# Containers
@onready var _cont_cells:Node2D = $Containers/Cells;
@onready var _cont_showOnZoom:Node2D = $Containers/show_on_zoom;
@onready var _cont_hideOnZoom:Node2D = $Containers/hide_on_zoom;
@onready var _cont_alwaysShow:Node2D = $Containers/always_show;
@onready var _cont_treasures:CanvasLayer = $Treasures;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		_Clear();
		_Generate_Map(randi());


func _ready() -> void:
	_Generate_Map(3);


func _Generate_Map(newSeed:int) -> void:

	_noiseTex.texture.noise.seed = newSeed;
	
	await _noiseTex.texture.changed;
	
	var noiseData:PackedByteArray = _noiseTex.get_texture().get_image().get_data();
	var elevationData:Array[Elevation] = _ElevationData_From_NoiseData(noiseData);
	
	_mapWidth = _noiseTex.get_texture().get_size().x;
	
	_CreateSprites_Cells(elevationData);
	_CreateSprites_Markings_And_Details(elevationData);


func _CreateSprites_Cells(elevationData:Array[Elevation]) -> void:
	
	var currX:int = 0;
	var currY:int = 0;
	
	for level in elevationData:
		
		# Create Sprite
		var cellSpr:Sprite2D = _Create_Sprite(0, 0, _spriteSheet);
		_cont_cells.add_child(cellSpr);
		
		# MOUTAIN
		if level == Elevation.HIGHEST:
			cellSpr.region_rect.position.x = _sprRegSize * 2;
		# HIGHLAND
		elif level == Elevation.HIGHER:
			cellSpr.region_rect.position.x = _sprRegSize * 3;
		# GROUND
		elif level == Elevation.HIGH:
			cellSpr.region_rect.position.x = _sprRegSize * 3;
		# COAST
		elif level == Elevation.MID:
			cellSpr.region_rect.position.x = _sprRegSize * 4;
		# SHALLOWS
		elif level == Elevation.LOW:
			cellSpr.modulate.a = _alphaThresh * 5;
		# SEA
		elif level == Elevation.LOWER:
			cellSpr.modulate.a = _alphaThresh * 2;
		# DEPTH
		elif level == Elevation.LOWEST:
			cellSpr.modulate.a = _alphaThresh * 1;
		# ABYSS
		elif level == Elevation.VOID:
			cellSpr.modulate.a = _alphaThresh * .25;
		
		#var rand:float = 1 - randf_range(0, .125);
		#cellSpr.modulate = Color(rand, rand, rand, cellSpr.modulate.a);
		
		# Position Sprite
		cellSpr.position = Vector2(currX * _cellSize, currY * _cellSize);
		#cellSpr.position.x = currX * _cellSize + randf_range(-.4, .4);
		#cellSpr.position.y = currY * _cellSize + randf_range(-.4, .4);
		cellSpr.rotation += randf_range(-.0625, .0625);
		
		# Set Next sprite Position
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
		
		_cell_sprites.append(cellSpr);


func _CreateSprites_Markings_And_Details(elevationData:Array[Elevation]) -> void:
	
	var currX:int = 0;
	var currY:int = 0;
	
	for level in elevationData:
		
		var marking:Sprite2D = null;
		
		var isTree:bool;
		var isHouse:bool;
		var isTreasure:bool;
		var isLighthouse:bool;
		
		# MOUTAIN
		if level == Elevation.HIGHEST:
			
			# House
			if randi_range(0, 1000) > 999:
				
				marking = _Create_Sprite(6, 7, _spriteSheet);
				_cont_hideOnZoom.add_child(marking);
				
				isHouse = true;
			# Tent
			elif randi_range(0, 1000) > 995:
				
				marking = _Create_Sprite(4, 9, _glyphs);
				_cont_showOnZoom.add_child(marking);
				
				marking.modulate = Color.BLACK;
			# Peak
			elif randi_range(0, 1000) > 200:
				
				marking = _Create_Sprite(3, 6, _spriteSheet);
				_cont_alwaysShow.add_child(marking);
				
				marking.scale *= randf_range(1, 1.5);
			# Hills
			else:
				
				marking = _Create_Sprite(9, 1, _glyphs);
				_cont_showOnZoom.add_child(marking);
				
				marking.modulate = Color.BLACK;
				marking.scale /= 1.5;
			
		# HIGHLAND
		elif level == Elevation.HIGHER:
			
			
			# Hills
			if randi_range(0, 1000) > 900:
				
				marking = _Create_Sprite(3, 8, _spriteSheet);
				_cont_showOnZoom.add_child(marking);
				
			# Tent
			elif randi_range(0, 1000) > 995:
				
				marking = _Create_Sprite(4, 9, _glyphs);
				_cont_showOnZoom.add_child(marking);
				
				marking.modulate = Color.BLACK;
				
		# GROUND
		elif level == Elevation.HIGH:
			
			# Tree
			if randi_range(0, 1000) > 600:
				
				marking = _Create_Sprite(7, 6, _spriteSheet);
				_cont_hideOnZoom.add_child(marking);
				
				isTree = true;
			# House
			elif randi_range(0, 1000) > 980:
				
				marking = _Create_Sprite(6, 7, _spriteSheet);
				_cont_hideOnZoom.add_child(marking);
				
				isHouse = true;
		
		# COAST
		elif level == Elevation.MID:
			
			# Lighthouse
			if randi_range(0, 1000) > 990:
				
				marking = _Create_Sprite(0, 11, _glyphs);
				_cont_hideOnZoom.add_child(marking);
				
				# Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = marking.position;
				#marking.add_child(lamp);
				
				isLighthouse = true;
			
			# Shell
			elif randi_range(0, 1000) > 990:
				
				marking = _Create_Sprite(6, 9, _glyphs);
				_cont_showOnZoom.add_child(marking);
				
				marking.modulate = Color.BLACK;
			
			# Tent
			if randi_range(0, 1000) > 995:
				
				marking = _Create_Sprite(4, 9, _glyphs);
				_cont_showOnZoom.add_child(marking);
			
				marking.modulate = Color.BLACK;
			
		# SHALLOWS
		elif level == Elevation.LOW:
			
			# Small Fish
			if randi_range(0, 1000) > 960:
				
				marking = _Create_Sprite(0, 7, _spriteSheet);
				_cont_showOnZoom.add_child(marking);
				
			# Jetty
			if randi_range(0, 1000) > 995:
				
				marking = _Create_Sprite(13, 12, _glyphs);
				_cont_showOnZoom.add_child(marking);
			
		# SEA
		elif level == Elevation.LOWER:
			
			# Big Fish
			if randi_range(0, 1000) > 990:
				
				marking = _Create_Sprite(1, 7, _spriteSheet);
				_cont_showOnZoom.add_child(marking);
			
		# DEPTHS
		elif level == Elevation.LOWEST:
			
			pass;
		
		# ABYSS
		elif level == Elevation.VOID:
			
			# Treasure
			if randf_range(0, 1000) > 997:
				
				marking = _Create_Sprite(9, 8, _spriteSheet);
				_cont_treasures.add_child(marking);
				
				var flicker:Treasure_Flicker = Treasure_Flicker.new();
				flicker.Set_CellSize(_cellSize);
				marking.add_child(flicker);

				isTreasure = true;
				
			# Whale
			elif randf_range(0, 1000) > 996:
				
				marking = _Create_Sprite(2, 5, _glyphs);
				_cont_showOnZoom.add_child(marking);
				
		
		if !marking:
			
			_marking_sprites.append(null);
		
		else:
			
			_marking_sprites.append(marking);
			
			# Position Marking
			marking.position = Vector2(currX * _cellSize, currY * _cellSize);
			#marking.position.x = currX * _cellSize + randf_range(-.4, .4);
			#marking.position.y = currY * _cellSize + randf_range(-.4, .4);
			
			if isTreasure:
				_detail_sprites.append(marking);
			else:
				marking.rotation += randf_range(-.125, .125);
			
			# Spawn Details
				
			if isTree:
				
				var tree:Sprite2D = _Create_Sprite(8, 6, _spriteSheet);
				_cont_showOnZoom.add_child(tree);
				
				tree.position = Vector2(currX * _cellSize, currY * _cellSize);
				#tree.position.x = currX * _cellSize + randf_range(-.4, .4);
				#tree.position.y = currY * _cellSize + randf_range(-.4, .4);
				
				tree.scale += Vector2.ONE * randf_range(-.01, .02);
				tree.offset.y -= _cellSize * 4;
				
				_detail_sprites.append(tree);
				
			elif isHouse:
				
				var house:Sprite2D = _Create_Sprite(randi_range(2, 4), 14, _spriteSheet);
				_cont_showOnZoom.add_child(house);
				
				house.position = Vector2(currX * _cellSize, currY * _cellSize);
				#house.position.x = currX * _cellSize;
				#house.position.y = currY * _cellSize - randf_range(0, _cellSize / 1.5);
				
				house.scale *= randf_range(1, 1.125);
				house.rotation += randf_range(-.125, .125);
				
				_detail_sprites.append(house);
				
			elif isLighthouse:
				
				var lighthouse:Sprite2D = _Create_Sprite(6, 12, _spriteSheet);
				_cont_showOnZoom.add_child(lighthouse);
				
				lighthouse.position = Vector2(currX * _cellSize, currY * _cellSize);
				#lighthouse.position.x = currX * _cellSize;
				#lighthouse.position.y = currY * _cellSize;
				
				lighthouse.region_rect.size = Vector2(256, 256 * 3);
				lighthouse.offset.y -= _sprRegSize + _sprRegSize / 2;
				
				_detail_sprites.append(lighthouse);
		
		if !isTree && !isHouse && !isLighthouse && !isTreasure:
			_detail_sprites.append(null);
		
		# Set Next marking Position
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
	
	# Hide Zoom Objects since we start zoomed Out
	_cont_showOnZoom.modulate.a = 0;
	
	#print(_cell_sprites.size());
	#print(_marking_sprites.size());
	#print(_detail_sprites.size());


func _Create_Sprite(regPosX:float, regPosY:float, tex:Texture2D) -> Sprite2D:
	
	var spr:Sprite2D = Sprite2D.new();
	
	spr.texture = tex;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(_sprRegSize, _sprRegSize);
	spr.region_rect.position = Vector2(regPosX, regPosY) * _sprRegSize;
	spr.scale /= _cellSize;
	
	return spr;


func _Clear() -> void:
	
	for c in _cont_cells.get_children(): c.queue_free();
	for c in _cont_showOnZoom.get_children(): c.queue_free();
	for c in _cont_hideOnZoom.get_children(): c.queue_free();
	for c in _cont_alwaysShow.get_children(): c.queue_free();
	for c in _cont_treasures.get_children(): c.queue_free();
	
	_cell_sprites = [];
	_marking_sprites = [];
	_detail_sprites = [];


# Functions: Data ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ElevationData_From_NoiseData(noiseData:Array) -> Array[Elevation]:
	
	var e:Array[Elevation];
	
	for d in noiseData:
		if d >= _highest:
			e.append(Elevation.HIGHEST);
			continue;
		elif d >= _higher && d < _highest:
			e.append(Elevation.HIGHER);
			continue;
		elif d >= _high && d < _higher:
			e.append(Elevation.HIGH);
			continue;
		elif d >= _mid && d < _high:
			e.append(Elevation.MID);
			continue;
		elif d >= _low && d < _mid:
			e.append(Elevation.LOW);
			continue;
		elif d >= _lower && d < _low:
			e.append(Elevation.LOWER);
			continue;
		elif d >= _lowest && d < _lower:
			e.append(Elevation.LOWEST);
			continue;
		elif d < _lowest:
			e.append(Elevation.VOID)
			continue;
	
	return e;


func _CellData_From_ElevationData(elevationData:Array[Elevation]) -> Array[Cell]:
	
	var cellData:Array[Cell];
	
	for level in elevationData:
		
		if level == Elevation.HIGHEST:
			cellData.append(Cell.MOUNTAIN);
			continue;
		elif level == Elevation.HIGHER:
			cellData.append(Cell.HIGHLAND);
			continue;
		elif level == Elevation.HIGH:
			cellData.append(Cell.GROUND);
			continue;
		elif level == Elevation.MID:
			cellData.append(Cell.COAST);
			continue;
		elif level == Elevation.LOW:
			cellData.append(Cell.SHALLOWS);
			continue;
		elif level == Elevation.LOWER:
			cellData.append(Cell.SEA);
			continue;
		elif level == Elevation.LOWEST:
			cellData.append(Cell.DEPTHS);
			continue;
		elif level == Elevation.VOID:
			cellData.append(Cell.ABYSS);
	
	return cellData;


#func _MarkingData_From_CellData(cellData:Array[Cell]) -> Array[Marking]:
	#return [];


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_CellSize(callerPath:String) -> float:
	print("Get_CellSize, Called by:", callerPath);
	return _cellSize;
