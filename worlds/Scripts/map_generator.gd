extends Node2D

const spriteSheet:Texture2D = preload("res://Sprites/Clack_Map_SpriteSheet_2048.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

const _cellSize:int = 16;
const _sprRegSize:float = 256;

@export var _noiseTex:TextureRect;
@onready var _cursor:Sprite2D = $Containers/Cursor;

@onready var _cells:Node2D = $Containers/Cells;

@onready var _show_on_zoom:Node2D = $Containers/show_on_zoom;
@onready var _hide_on_zoom:Node2D = $Containers/hide_on_zoom;
@onready var _always_show:Node2D = $Containers/always_show;
#@onready var _trees:Node2D = $"Containers/objects/Trees";
#@onready var _houses:Node2D = $"Containers/objects/houses";

@onready var _treasures:CanvasLayer = $Treasures;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	# Get Noise Data
	_noiseTex.texture.noise.seed = randi();
	await _noiseTex.texture.changed;
	var noiseData:Array = _noiseTex.get_texture().get_image().get_data();
	
	# Set World Parameters
	var mapWidth:float = sqrt(noiseData.size());
	var currX:int = 0;
	var currY:int = 0;
	
	var levels:float = 5.0;
	var noiseRange:float = 255;
	var threshold:float = noiseRange / levels;
	var alphaThresh:float = 1.0 / levels;
	
	var top:float = 4.25;
	var higher:float = 3.07;
	var high:float = 3.05
	var upperMid:float = 3;
	var mid:float = 2.75;
	var low:float = 2.25;
	var bottom:float = 1.25;
	
	for d in noiseData:
		
		# Create Sprite
		var cellSpr:Sprite2D = _NewSprite(0, 0, spriteSheet);
		_cells.add_child(cellSpr);
		
		var object:Sprite2D = null;
		
		var isTree:bool;
		var isHouse:bool;
		var isTreasure:bool;
		var isLighthouse:bool;
		
		# Elevation: START ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		
		# Top
		if d >= threshold * top:
			
			# House
			if randi_range(0, 1000) > 999:
				object = _NewSprite(6, 7, spriteSheet);
				_hide_on_zoom.add_child(object);
				#_houses.add_child(object);
				isHouse = true;
			# Tent
			elif randi_range(0, 1000) > 995:
				object = _NewSprite(4, 9, _glyphs);
				object.modulate = Color.BLACK;
				_show_on_zoom.add_child(object);
			# Peak
			elif randi_range(0, 1000) > 200:
				object = _NewSprite(3, 6, spriteSheet);
				_always_show.add_child(object);
				object.scale *= randf_range(1, 1.5);
			# Hills
			else:
				object = _NewSprite(9, 1, _glyphs);
				_show_on_zoom.add_child(object);
				object.modulate = Color.BLACK;
				object.scale /= 1.5;
			
			cellSpr.region_rect.position.x = _sprRegSize * 2;
		
		# Higher: Green
		elif d >= threshold * higher && d < threshold * top:
			
			# Tree
			if randi_range(0, 1000) > 600:
				object = _NewSprite(7, 6, spriteSheet);
				_hide_on_zoom.add_child(object);
				#_trees.add_child(object);
				isTree = true;
			# House
			elif randi_range(0, 1000) > 980:
				object = _NewSprite(6, 7, spriteSheet);
				_hide_on_zoom.add_child(object);
				#_houses.add_child(object);
				isHouse = true;
				#object.modulate.a = 0.75;
			# Hills
			elif randi_range(0, 1000) > 900:
				object = _NewSprite(3, 8, spriteSheet);
				_show_on_zoom.add_child(object);
			# Tent
			elif randi_range(0, 1000) > 995:
				object = _NewSprite(4, 9, _glyphs);
				object.modulate = Color.BLACK;
				_show_on_zoom.add_child(object);
				
			cellSpr.region_rect.position.x = _sprRegSize * 3;
		
		# High: Green Edges
		elif d >= threshold * high && d < threshold * higher:
			
			# Lighthouse
			if randi_range(0, 1000) > 980:
				object = _NewSprite(0, 11, _glyphs);
				# Lamp
				var lamp:PointLight2D = _lighthouseLamp.instantiate();
				lamp.position = object.position;
				object.add_child(lamp);
				
				_hide_on_zoom.add_child(object);
				
				isLighthouse = true;
			
			cellSpr.region_rect.position.x = _sprRegSize * 3;
			#spr.region_rect.position.x = _sprRegSize * 8;
		
		# Upper Mid: Coast
		elif d >= threshold * upperMid && d < threshold * higher:
			
			if randi_range(0, 1000) > 995:
				# Shell
				if randi_range(0, 1000) > 500:
					object = _NewSprite(6, 9, _glyphs);
				# Tent
				else:
					object = _NewSprite(4, 9, _glyphs);
				
				object.modulate = Color.BLACK;
				_show_on_zoom.add_child(object);
			
			cellSpr.region_rect.position.x = _sprRegSize * 4;
		
		# Mid
		elif d >= threshold * mid && d < threshold * upperMid:
			
			# Small Fish
			if randi_range(0, 1000) > 960:
				object = _NewSprite(0, 7, spriteSheet);
				_show_on_zoom.add_child(object);
			# Jetty
			if randi_range(0, 1000) > 995:
				object = _NewSprite(13, 12, _glyphs);
				_show_on_zoom.add_child(object);
			
			cellSpr.modulate.a = alphaThresh * 5;
		
		# Low
		elif d >= threshold * low && d < threshold * mid:
			
			# Big Fish
			if randi_range(0, 1000) > 990:
				object = _NewSprite(1, 7, spriteSheet);
				_show_on_zoom.add_child(object);
			
			cellSpr.modulate.a = alphaThresh * 2;
		
		# Bottom
		elif d >= threshold * bottom && d < threshold * low:
			
			cellSpr.modulate.a = alphaThresh * 1;
		
		elif d < threshold * bottom:
			
			# Treasure
			if randf_range(0, 1000) > 997:
				object = _NewSprite(9, 8, spriteSheet);
				var flicker:Treasure_Flicker = Treasure_Flicker.new();
				flicker.Set_CellSize(_cellSize);
				object.add_child(flicker);
				_treasures.add_child(object);
				isTreasure = true;
			# Whale
			elif randf_range(0, 1000) > 996:
				object = _NewSprite(2, 5, _glyphs);
				_show_on_zoom.add_child(object);
			
			cellSpr.modulate.a = alphaThresh * .25;
		
		# Elevation: END ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		
		var rand:float = 1 - randf_range(0, .125);
		cellSpr.modulate = Color(rand, rand, rand, cellSpr.modulate.a);
		
		# Position Sprite
		cellSpr.position.x = currX * _cellSize + randf_range(-.4, .4);
		cellSpr.position.y = currY * _cellSize + randf_range(-.4, .4);
		cellSpr.rotation += randf_range(-.0625, .0625);
		
		if object:
			object.position.x = currX * _cellSize + randf_range(-.4, .4);
			object.position.y = currY * _cellSize + randf_range(-.4, .4);
			
			if !isTreasure:
				object.rotation += randf_range(-.125, .125);
				
			if isTree:
				var tree:Sprite2D = _NewSprite(8, 6, spriteSheet);
				tree.offset.y -= _cellSize * 4;
				_show_on_zoom.add_child(tree);
				tree.position.x = currX * _cellSize + randf_range(-.4, .4);
				tree.position.y = currY * _cellSize + randf_range(-.4, .4);
				tree.scale += Vector2.ONE * randf_range(-.01, .02);
				#tree.rotation += randf_range(-.125, .125);
				
			if isHouse:
				var house:Sprite2D = _NewSprite(randi_range(2, 4), 14, spriteSheet);
				_show_on_zoom.add_child(house);
				#house.region_rect.size *= 2;
				house.position.x = currX * _cellSize;
				house.position.y = currY * _cellSize - randf_range(0, _cellSize / 1.5);
				house.scale *= randf_range(1, 1.125);
				#house.scale.y *= randf_range(1, 1.5);
				house.rotation += randf_range(-.125, .125);
				
			if isLighthouse:
				var lighthouse:Sprite2D = _NewSprite(6, 12, spriteSheet, Vector2(256, 256 * 3));
				#lighthouse.centered = false;
				#var lighthouse:Sprite2D = _NewSprite(4, 14, spriteSheet, Vector2(1, 1));
				lighthouse.offset.y -= _sprRegSize + _sprRegSize / 2;
				_show_on_zoom.add_child(lighthouse);
				lighthouse.position.x = currX * _cellSize;
				lighthouse.position.y = currY * _cellSize;
				#lighthouse.position.y = currY * _cellSize - _cellSize / 2;
		
		# Set Next sprite Position
		currX += 1;
		
		if currX >= mapWidth:
			currX = 0;
			currY += 1;
	
	# Hide Zoom Objects since we start zoomed Out
	_show_on_zoom.modulate.a = 0;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _NewSprite(regPosX:float, regPosY:float, tex:Texture2D, regSize:Vector2 = Vector2.ZERO) -> Sprite2D:
	
	var spr:Sprite2D = Sprite2D.new();
	
	spr.texture = tex;
		
	spr.region_enabled = true;
	
	# Region Size
	
	if regSize != Vector2.ZERO:
		spr.region_rect.size = regSize;
	else:
		spr.region_rect.size = Vector2(_sprRegSize, _sprRegSize);
		
	spr.scale /= _cellSize;
	
	# Region Position
	
	spr.region_rect.position.x = _sprRegSize * regPosX;
	spr.region_rect.position.y = _sprRegSize * regPosY;
	
	return spr;


func _Cells_From_Noise(noiseData:Array) -> Array[String]:
	
	var cells:Array[String] = [];
	
	# Set World Parameters
	var mapWidth:float = sqrt(noiseData.size());
	
	var levels:float = 5.0;
	var noiseRange:float = 255;
	var threshold:float = noiseRange / levels;
	
	var top:float = 4.25;
	var higher:float = 3.1;
	var high:float = 3.05;
	var upperMid:float = 3;
	var mid:float = 2.75;
	var low:float = 2.25;
	var bottom:float = 1.25;
	
	for d in noiseData:
		# Top
		if d >= threshold * top:
			cells.append("Mountain");
		# Higher
		elif d >= threshold * higher && d < threshold * top:
			cells.append("Green");
		# High: Green Edges
		elif d >= threshold * high && d < threshold * higher:
			cells.append("Green Edges");
		# UpperMid: Coast
		elif d >= threshold * upperMid && d < threshold * high:
			cells.append("Coast");
		# Mid
		elif d >= threshold * mid && d < threshold * upperMid:
			cells.append("Shallows");
		# Low
		elif d >= threshold * low && d < threshold * mid:
			cells.append("Deep");
		# Bottom
		elif d >= threshold * bottom && d < threshold * low:
			cells.append("Sea");
		# Black
		elif d < threshold * bottom:
			cells.append("Abyss");
		
	return(cells);


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_CellSize(callerPath:String) -> float:
	print("Get_CellSize, Called by:", callerPath);
	return _cellSize;
