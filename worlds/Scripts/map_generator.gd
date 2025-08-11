extends Node2D

const spriteSheet:Texture2D = preload("res://Sprites/Clack_Map_SpriteSheet_2048.png");
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");

const _cellSize:int = 16;
const _sprRegSize:float = 256;

@export var _noiseTex:TextureRect;

@onready var _cells:Node2D = $Cells;

@onready var _treasures:CanvasLayer = $Treasures;

@onready var _objects:Node2D = $objects;
@onready var _trees:Node2D = $"objects/Trees";
@onready var _houses:Node2D = $"objects/houses";

@onready var _zoom_objects:Node2D = $zoom_objects;


func _Cells_From_Noise(noiseData:Array) -> Array[String]:
	
	var cells:Array[String] = [];
	
	# Set World Parameters
	var mapWidth:float = sqrt(noiseData.size());
	
	var levels:float = 5.0;
	var noiseRange:float = 255;
	var threshold:float = noiseRange / levels;
	
	var top:float = 4.25;
	var higher:float = 3.1;
	var high:float = 3;
	var mid:float = 2.75;
	var low:float = 2.25;
	var bottom:float = 1.25;
	
	for d in noiseData:
		# Top
		if d >= threshold * top:
			cells.append("Mountain");
		# Higher
		if d >= threshold * higher && d < threshold * top:
			cells.append("Green");
		# High: Coast
		elif d >= threshold * high && d < threshold * higher:
			cells.append("Coast");
		# Mid
		elif d >= threshold * mid && d < threshold * high:
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
	var higher:float = 3.1;
	var high:float = 3;
	var mid:float = 2.75;
	var low:float = 2.25;
	var bottom:float = 1.25;
	
	for d in noiseData:
		
		# Create Sprite
		var spr:Sprite2D = _NewSprite(0, 0);
		_cells.add_child(spr);
		
		var object:Sprite2D = null;
		
		var isTree:bool;
		var isHouse:bool;
		var isTreasure:bool;
		
		# Elevation: START ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		
		# Top
		if d >= threshold * top:
			
			# Mountains
			if randi_range(0, 1000) > 100:
			
				# House
				if randi_range(0, 1000) > 999:
					object = _NewSprite(6, 7);
					_houses.add_child(object);
					isHouse = true;
				# Tent
				elif randi_range(0, 1000) > 995:
					object = _NewSprite(4, 9, _glyphs);
					object.modulate = Color.BLACK;
					_zoom_objects.add_child(object);
				# Peak
				else:
					object = _NewSprite(3, 6);
					_objects.add_child(object);
					object.scale *= randf_range(1, 1.5);
				
				spr.region_rect.position.x = _sprRegSize * 2;
				
			# Hills
			else:
				object = _NewSprite(3, 8);
				_zoom_objects.add_child(object);
				spr.region_rect.position.x = _sprRegSize * 3;
		
		# Higher
		if d >= threshold * higher && d < threshold * top:
			
			# Tree
			if randi_range(0, 1000) > 600:
				object = _NewSprite(7, 6);
				_trees.add_child(object);
				isTree = true;
			# House
			elif randi_range(0, 1000) > 980:
				object = _NewSprite(6, 7);
				_houses.add_child(object);
				isHouse = true;
				#object.modulate.a = 0.75;
			# Hills
			elif randi_range(0, 1000) > 900:
				object = _NewSprite(3, 8);
				_zoom_objects.add_child(object);
			# Tent
			elif randi_range(0, 1000) > 995:
				object = _NewSprite(4, 9, _glyphs);
				object.modulate = Color.BLACK;
				_zoom_objects.add_child(object);
				
			spr.region_rect.position.x = _sprRegSize * 3;
		
		# High: Coast
		elif d >= threshold * high && d < threshold * higher:
			
			if randi_range(0, 1000) > 995:
				# Shell
				if randi_range(0, 1000) > 500:
					object = _NewSprite(6, 9, _glyphs);
				# Tent
				else:
					object = _NewSprite(4, 9, _glyphs);
				
				object.modulate = Color.BLACK;
				_zoom_objects.add_child(object);
			
			spr.region_rect.position.x = _sprRegSize * 4;
		
		# Mid
		elif d >= threshold * mid && d < threshold * high:
			
			# Small Fish
			if randi_range(0, 1000) > 960:
				object = _NewSprite(0, 7);
				_zoom_objects.add_child(object);
			# Boats
			if randi_range(0, 1000) > 995:
				object = _NewSprite(1, 6);
				_zoom_objects.add_child(object);
			
			spr.modulate.a = alphaThresh * 5;
		
		# Low
		elif d >= threshold * low && d < threshold * mid:
			
			# Big Fish
			if randi_range(0, 1000) > 990:
				object = _NewSprite(1, 7);
				_zoom_objects.add_child(object);
			
			spr.modulate.a = alphaThresh * 2;
		
		# Bottom
		elif d >= threshold * bottom && d < threshold * low:
			
			spr.modulate.a = alphaThresh * 1;
		
		elif d < threshold * bottom:
			
			# Treasure
			if randi_range(0, 1000) > 990:
				object = _NewSprite(9, 8);
				var flicker:Treasure_Flicker = Treasure_Flicker.new();
				flicker.Set_CellSize(_cellSize);
				object.add_child(flicker);
				_treasures.add_child(object);
				isTreasure = true;
			
			spr.modulate.a = alphaThresh * .25;
		
		# Elevation: END ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		
		var rand:float = 1 - randf_range(0, .125);
		spr.modulate = Color(rand, rand, rand, spr.modulate.a);
		
		# Position Sprite
		spr.position.x = currX * _cellSize + randf_range(-.4, .4);
		spr.position.y = currY * _cellSize + randf_range(-.4, .4);
		spr.rotation += randf_range(-.0625, .0625);
		
		if object:
			object.position.x = currX * _cellSize + randf_range(-.4, .4);
			object.position.y = currY * _cellSize + randf_range(-.4, .4);
			
			if !isTreasure:
				object.rotation += randf_range(-.125, .125);
				
			if isTree:
				var tree:Sprite2D = _NewSprite(8, 6);
				tree.offset.y -= _cellSize * 4;
				_zoom_objects.add_child(tree);
				tree.position.x = currX * _cellSize + randf_range(-.4, .4);
				tree.position.y = currY * _cellSize + randf_range(-.4, .4);
				tree.scale += Vector2.ONE * randf_range(-.01, .02);
				#tree.rotation += randf_range(-.125, .125);
				
			if isHouse:
				var house:Sprite2D = _NewSprite(0, 14);
				_zoom_objects.add_child(house);
				house.region_rect.size *= 2;
				house.position.x = currX * _cellSize;
				house.position.y = currY * _cellSize - randf_range(0, _cellSize / 2);
				house.scale /= 2;
				house.scale.y *= randf_range(1, 1.5);
				#house.rotation += randf_range(-.125, .125);
		
		# Set Next sprite Position
		currX += 1;
		
		if currX >= mapWidth:
			currX = 0;
			currY += 1;
	
	# Hide Zoom Objects since we start zoomed Out
	_zoom_objects.modulate.a = 0;


func _NewSprite(regPosX:float, regPosY:float, altTex:Texture2D = null) -> Sprite2D:
	
	var spr:Sprite2D = Sprite2D.new();
	
	# Assign Texture
	if !altTex:
		spr.texture = spriteSheet;
	else:
		spr.texture = altTex;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(_sprRegSize, _sprRegSize);
	spr.scale /= _cellSize;
	
	spr.region_rect.position.x = _sprRegSize * regPosX;
	spr.region_rect.position.y = _sprRegSize * regPosY;
	
	return spr;
