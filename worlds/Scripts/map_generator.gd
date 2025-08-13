extends Node2D

enum Elevation { Null, LOWEST, LOWER, LOW, MID, HIGH, HIGHER, HIGHEST, VOID }

@export var _highest:float = 230;
@export var _higher:float = 220;
@export var _high:float = 210;
@export var _mid:float = 150;
@export var _low:float = 90;
@export var _lower:float = 70;
@export var _lowest:float = 50;

const _levelCount:float = 4.0;
const _alphaThresh:float = 1.0 / _levelCount;

# Resources
const _spriteSheet:Texture2D = preload("res://Sprites/Clack_Map_SpriteSheet_2048.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

# World
const _cellSize:int = 16;
const _sprRegSize:float = 256;
var _mapWidth:float;

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


func _Generate_Map(seed:int) -> void:

	_noiseTex.texture.noise.seed = seed;
	
	await _noiseTex.texture.changed;
	
	var noiseData:PackedByteArray = _noiseTex.get_texture().get_image().get_data();
	var elevation:Array[Elevation] = _Elevation_From_Noise(noiseData);
	
	_mapWidth = _noiseTex.get_texture().get_size().x;
	
	_Spawn_Cells(elevation);
	_Spawn_Objects(elevation);


func _Spawn_Cells(elevation:Array[Elevation]) -> void:
	
	var currX:int = 0;
	var currY:int = 0;
	
	for level in elevation:
		
		# Create Sprite
		var cellSpr:Sprite2D = _Create_Sprite(0, 0, _spriteSheet);
		_cont_cells.add_child(cellSpr);
		
		if level == Elevation.HIGHEST:
			cellSpr.region_rect.position.x = _sprRegSize * 2;
			
		elif level == Elevation.HIGHER:
			cellSpr.region_rect.position.x = _sprRegSize * 3;
			
		elif level == Elevation.HIGH:
			cellSpr.region_rect.position.x = _sprRegSize * 3;
			
		elif level == Elevation.MID:
			cellSpr.region_rect.position.x = _sprRegSize * 4;
			
		elif level == Elevation.LOW:
			cellSpr.modulate.a = _alphaThresh * 5;
			
		elif level == Elevation.LOWER:
			cellSpr.modulate.a = _alphaThresh * 2;
			
		elif level == Elevation.LOWEST:
			cellSpr.modulate.a = _alphaThresh * 1;
			
		elif level == Elevation.VOID:
			cellSpr.modulate.a = _alphaThresh * .25;
		
		var rand:float = 1 - randf_range(0, .125);
		cellSpr.modulate = Color(rand, rand, rand, cellSpr.modulate.a);
		
		# Position Sprite
		cellSpr.position.x = currX * _cellSize + randf_range(-.4, .4);
		cellSpr.position.y = currY * _cellSize + randf_range(-.4, .4);
		cellSpr.rotation += randf_range(-.0625, .0625);
		
		# Set Next sprite Position
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;


func _Spawn_Objects(elevation:Array[Elevation]) -> void:
	
	var currX:int = 0;
	var currY:int = 0;
	
	for level in elevation:
		
		var object:Sprite2D = null;
		
		var isTree:bool;
		var isHouse:bool;
		var isTreasure:bool;
		var isLighthouse:bool;
		
		if level == Elevation.HIGHEST:
			
			# House
			if randi_range(0, 1000) > 999:
				
				object = _Create_Sprite(6, 7, _spriteSheet);
				_cont_hideOnZoom.add_child(object);
				
				isHouse = true;
			# Tent
			elif randi_range(0, 1000) > 995:
				
				object = _Create_Sprite(4, 9, _glyphs);
				_cont_showOnZoom.add_child(object);
				
				object.modulate = Color.BLACK;
			# Peak
			elif randi_range(0, 1000) > 200:
				
				object = _Create_Sprite(3, 6, _spriteSheet);
				_cont_alwaysShow.add_child(object);
				
				object.scale *= randf_range(1, 1.5);
			# Hills
			else:
				
				object = _Create_Sprite(9, 1, _glyphs);
				_cont_showOnZoom.add_child(object);
				
				object.modulate = Color.BLACK;
				object.scale /= 1.5;
			
		
		elif level == Elevation.HIGHER:
			
			# Tree
			if randi_range(0, 1000) > 600:
				
				object = _Create_Sprite(7, 6, _spriteSheet);
				_cont_hideOnZoom.add_child(object);
				
				isTree = true;
			# House
			elif randi_range(0, 1000) > 980:
				
				object = _Create_Sprite(6, 7, _spriteSheet);
				_cont_hideOnZoom.add_child(object);
				
				isHouse = true;
			# Hills
			elif randi_range(0, 1000) > 900:
				
				object = _Create_Sprite(3, 8, _spriteSheet);
				_cont_showOnZoom.add_child(object);
				
			# Tent
			elif randi_range(0, 1000) > 995:
				
				object = _Create_Sprite(4, 9, _glyphs);
				_cont_showOnZoom.add_child(object);
				
				object.modulate = Color.BLACK;
				
		
		elif level == Elevation.HIGH:
			
			# Lighthouse
			if randi_range(0, 1000) > 980:
				
				object = _Create_Sprite(0, 11, _glyphs);
				_cont_hideOnZoom.add_child(object);
				
				# Lamp
				var lamp:PointLight2D = _lighthouseLamp.instantiate();
				lamp.position = object.position;
				object.add_child(lamp);
				
				isLighthouse = true;
		
		elif level == Elevation.MID:
			
			if randi_range(0, 1000) > 995:
				# Shell
				if randi_range(0, 1000) > 500:
					
					object = _Create_Sprite(6, 9, _glyphs);
					_cont_showOnZoom.add_child(object);
					
				# Tent
				else:
					
					object = _Create_Sprite(4, 9, _glyphs);
					_cont_showOnZoom.add_child(object);
				
				object.modulate = Color.BLACK;
			
		
		elif level == Elevation.LOW:
			
			# Small Fish
			if randi_range(0, 1000) > 960:
				
				object = _Create_Sprite(0, 7, _spriteSheet);
				_cont_showOnZoom.add_child(object);
				
			# Jetty
			if randi_range(0, 1000) > 995:
				
				object = _Create_Sprite(13, 12, _glyphs);
				_cont_showOnZoom.add_child(object);
			
		
		elif level == Elevation.LOWER:
			
			# Big Fish
			if randi_range(0, 1000) > 990:
				
				object = _Create_Sprite(1, 7, _spriteSheet);
				_cont_showOnZoom.add_child(object);
			
		
		elif level == Elevation.LOWEST:
			
			pass;
			
		elif level == Elevation.VOID:
			
			# Treasure
			if randf_range(0, 1000) > 997:
				
				object = _Create_Sprite(9, 8, _spriteSheet);
				_cont_treasures.add_child(object);
				
				var flicker:Treasure_Flicker = Treasure_Flicker.new();
				flicker.Set_CellSize(_cellSize);
				object.add_child(flicker);

				isTreasure = true;
			# Whale
			elif randf_range(0, 1000) > 996:
				
				object = _Create_Sprite(2, 5, _glyphs);
				_cont_showOnZoom.add_child(object);
			
		
		if object:
			object.position.x = currX * _cellSize + randf_range(-.4, .4);
			object.position.y = currY * _cellSize + randf_range(-.4, .4);
			
			if !isTreasure:
				object.rotation += randf_range(-.125, .125);
				
			if isTree:
				var tree:Sprite2D = _Create_Sprite(8, 6, _spriteSheet);
				_cont_showOnZoom.add_child(tree);
				
				tree.position.x = currX * _cellSize + randf_range(-.4, .4);
				tree.position.y = currY * _cellSize + randf_range(-.4, .4);
				
				tree.scale += Vector2.ONE * randf_range(-.01, .02);
				tree.offset.y -= _cellSize * 4;
				
			if isHouse:
				
				var house:Sprite2D = _Create_Sprite(randi_range(2, 4), 14, _spriteSheet);
				_cont_showOnZoom.add_child(house);
				
				house.position.x = currX * _cellSize;
				house.position.y = currY * _cellSize - randf_range(0, _cellSize / 1.5);
				
				house.scale *= randf_range(1, 1.125);
				house.rotation += randf_range(-.125, .125);
				
			if isLighthouse:
				
				var lighthouse:Sprite2D = _Create_Sprite(6, 12, _spriteSheet);
				_cont_showOnZoom.add_child(lighthouse);
				
				lighthouse.position.x = currX * _cellSize;
				lighthouse.position.y = currY * _cellSize;
				
				lighthouse.region_rect.size = Vector2(256, 256 * 3);
				lighthouse.offset.y -= _sprRegSize + _sprRegSize / 2;
		
		# Set Next sprite Position
		currX += 1;
		if currX >= _mapWidth:
			currX = 0;
			currY += 1;
	
	# Hide Zoom Objects since we start zoomed Out
	_cont_showOnZoom.modulate.a = 0;


func _Elevation_From_Noise(noiseData:Array) -> Array[Elevation]:
	
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


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_CellSize(callerPath:String) -> float:
	print("Get_CellSize, Called by:", callerPath);
	return _cellSize;


# TEMP ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# TEMP ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# TEMP ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# TEMP ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# TEMP ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


#func S() -> void:
	#
	## Get Noise Data
	##_noiseTex.texture.noise.seed = randi();
	#_noiseTex.texture.noise.seed = 3;
	#await _noiseTex.texture.changed;
	#var noiseData:Array = _noiseTex.get_texture().get_image().get_data();
	#
	## Set World Parameters
	#var mapWidth:float = sqrt(noiseData.size());
	#var currX:int = 0;
	#var currY:int = 0;
	#
	#var levelCount:float = 5.0;
	#var noiseRange:float = 255;
	#var threshold:float = noiseRange / levelCount;
	#var _alphaThresh:float = 1.0 / levelCount;
	#
	#var top:float = 4.25;
	#var higher:float = 3.07;
	#var high:float = 3.05
	#var upperMid:float = 3;
	#var mid:float = 2.75;
	#var low:float = 2.25;
	#var bottom:float = 1.25;
	#
	#for d in noiseData:
		#
		## Create Sprite
		#var cellSpr:Sprite2D = _Create_Sprite(0, 0, _spriteSheet);
		#_cont_cells.add_child(cellSpr);
		#
		#var object:Sprite2D = null;
		#
		#var isTree:bool;
		#var isHouse:bool;
		#var isTreasure:bool;
		#var isLighthouse:bool;
		#
		## Elevation: START ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		#
		## Top
		#if d >= threshold * top:
			#
			## House
			#if randi_range(0, 1000) > 999:
				#object = _Create_Sprite(6, 7, _spriteSheet);
				#_cont_hideOnZoom.add_child(object);
				##_houses.add_child(object);
				#isHouse = true;
			## Tent
			#elif randi_range(0, 1000) > 995:
				#object = _Create_Sprite(4, 9, _glyphs);
				#object.modulate = Color.BLACK;
				#_cont_showOnZoom.add_child(object);
			## Peak
			#elif randi_range(0, 1000) > 200:
				#object = _Create_Sprite(3, 6, _spriteSheet);
				#_cont_alwaysShow.add_child(object);
				#object.scale *= randf_range(1, 1.5);
			## Hills
			#else:
				#object = _Create_Sprite(9, 1, _glyphs);
				#_cont_showOnZoom.add_child(object);
				#object.modulate = Color.BLACK;
				#object.scale /= 1.5;
			#
			#cellSpr.region_rect.position.x = _sprRegSize * 2;
		#
		## Higher: Green
		#elif d >= threshold * higher && d < threshold * top:
			#
			## Tree
			#if randi_range(0, 1000) > 600:
				#object = _Create_Sprite(7, 6, _spriteSheet);
				#_cont_hideOnZoom.add_child(object);
				##_trees.add_child(object);
				#isTree = true;
			## House
			#elif randi_range(0, 1000) > 980:
				#object = _Create_Sprite(6, 7, _spriteSheet);
				#_cont_hideOnZoom.add_child(object);
				##_houses.add_child(object);
				#isHouse = true;
				##object.modulate.a = 0.75;
			## Hills
			#elif randi_range(0, 1000) > 900:
				#object = _Create_Sprite(3, 8, _spriteSheet);
				#_cont_showOnZoom.add_child(object);
			## Tent
			#elif randi_range(0, 1000) > 995:
				#object = _Create_Sprite(4, 9, _glyphs);
				#object.modulate = Color.BLACK;
				#_cont_showOnZoom.add_child(object);
				#
			#cellSpr.region_rect.position.x = _sprRegSize * 3;
		#
		## High: Green Edges
		#elif d >= threshold * high && d < threshold * higher:
			#
			## Lighthouse
			#if randi_range(0, 1000) > 980:
				#object = _Create_Sprite(0, 11, _glyphs);
				## Lamp
				#var lamp:PointLight2D = _lighthouseLamp.instantiate();
				#lamp.position = object.position;
				#object.add_child(lamp);
				#
				#_cont_hideOnZoom.add_child(object);
				#
				#isLighthouse = true;
			#
			#cellSpr.region_rect.position.x = _sprRegSize * 3;
			##spr.region_rect.position.x = _sprRegSize * 8;
		#
		## Upper Mid: Coast
		#elif d >= threshold * upperMid && d < threshold * higher:
			#
			#if randi_range(0, 1000) > 995:
				## Shell
				#if randi_range(0, 1000) > 500:
					#object = _Create_Sprite(6, 9, _glyphs);
				## Tent
				#else:
					#object = _Create_Sprite(4, 9, _glyphs);
				#
				#object.modulate = Color.BLACK;
				#_cont_showOnZoom.add_child(object);
			#
			#cellSpr.region_rect.position.x = _sprRegSize * 4;
		#
		## Mid
		#elif d >= threshold * mid && d < threshold * upperMid:
			#
			## Small Fish
			#if randi_range(0, 1000) > 960:
				#object = _Create_Sprite(0, 7, _spriteSheet);
				#_cont_showOnZoom.add_child(object);
			## Jetty
			#if randi_range(0, 1000) > 995:
				#object = _Create_Sprite(13, 12, _glyphs);
				#_cont_showOnZoom.add_child(object);
			#
			#cellSpr.modulate.a = _alphaThresh * 5;
		#
		## Low
		#elif d >= threshold * low && d < threshold * mid:
			#
			## Big Fish
			#if randi_range(0, 1000) > 990:
				#object = _Create_Sprite(1, 7, _spriteSheet);
				#_cont_showOnZoom.add_child(object);
			#
			#cellSpr.modulate.a = _alphaThresh * 2;
		#
		## Bottom
		#elif d >= threshold * bottom && d < threshold * low:
			#
			#cellSpr.modulate.a = _alphaThresh * 1;
		#
		#elif d < threshold * bottom:
			#
			## Treasure
			#if randf_range(0, 1000) > 997:
				#object = _Create_Sprite(9, 8, _spriteSheet);
				#var flicker:Treasure_Flicker = Treasure_Flicker.new();
				#flicker.Set_CellSize(_cellSize);
				#object.add_child(flicker);
				#_cont_treasures.add_child(object);
				#isTreasure = true;
			## Whale
			#elif randf_range(0, 1000) > 996:
				#object = _Create_Sprite(2, 5, _glyphs);
				#_cont_showOnZoom.add_child(object);
			#
			#cellSpr.modulate.a = _alphaThresh * .25;
		#
		## Elevation: END ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		#
		#var rand:float = 1 - randf_range(0, .125);
		#cellSpr.modulate = Color(rand, rand, rand, cellSpr.modulate.a);
		#
		## Position Sprite
		#cellSpr.position.x = currX * _cellSize + randf_range(-.4, .4);
		#cellSpr.position.y = currY * _cellSize + randf_range(-.4, .4);
		#cellSpr.rotation += randf_range(-.0625, .0625);
		#
		#if object:
			#object.position.x = currX * _cellSize + randf_range(-.4, .4);
			#object.position.y = currY * _cellSize + randf_range(-.4, .4);
			#
			#if !isTreasure:
				#object.rotation += randf_range(-.125, .125);
				#
			#if isTree:
				#var tree:Sprite2D = _Create_Sprite(8, 6, _spriteSheet);
				#tree.offset.y -= _cellSize * 4;
				#_cont_showOnZoom.add_child(tree);
				#tree.position.x = currX * _cellSize + randf_range(-.4, .4);
				#tree.position.y = currY * _cellSize + randf_range(-.4, .4);
				#tree.scale += Vector2.ONE * randf_range(-.01, .02);
				##tree.rotation += randf_range(-.125, .125);
				#
			#if isHouse:
				#var house:Sprite2D = _Create_Sprite(randi_range(2, 4), 14, _spriteSheet);
				#_cont_showOnZoom.add_child(house);
				##house.region_rect.size *= 2;
				#house.position.x = currX * _cellSize;
				#house.position.y = currY * _cellSize - randf_range(0, _cellSize / 1.5);
				#house.scale *= randf_range(1, 1.125);
				##house.scale.y *= randf_range(1, 1.5);
				#house.rotation += randf_range(-.125, .125);
				#
			#if isLighthouse:
				#var lighthouse:Sprite2D = _Create_Sprite(6, 12, _spriteSheet);
				##lighthouse.centered = false;
				##var lighthouse:Sprite2D = _Create_Sprite(4, 14, _spriteSheet, Vector2(1, 1));
				#lighthouse.region_rect.size = Vector2(256, 256 * 3);
				#lighthouse.offset.y -= _sprRegSize + _sprRegSize / 2;
				#_cont_showOnZoom.add_child(lighthouse);
				#lighthouse.position.x = currX * _cellSize;
				#lighthouse.position.y = currY * _cellSize;
				##lighthouse.position.y = currY * _cellSize - _cellSize / 2;
		#
		## Set Next sprite Position
		#currX += 1;
		#
		#if currX >= mapWidth:
			#currX = 0;
			#currY += 1;
	#
	## Hide Zoom Objects since we start zoomed Out
	#_cont_showOnZoom.modulate.a = 0;
