extends Node2D

# Resources
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
	920171824,
	2219318034, # Cut through the Mountains
	2912471184,
	1970006309, # Leviathan
	429314510,
	787546645, # Big Boy
	3790769020, # The Howl
	2239492294,
	2989861102,
	1223885537,
	];
#const _lighthouseLamp:PackedScene = preload("res://Prefabs/lighthouse_lamp.tscn");

# Thresholds
@export var _mountain:float = 245 - 20;
@export var _forest:float = 220 - 20;
@export var _ground:float = 200 - 20;
@export var _shore:float = 190 - 20;
@export var _shallow:float = 180 - 20;
@export var _sea:float = 160 - 20;
@export var _ocean:float = 130 - 20;
@export var _depths:float = 80 - 20;
# Water Depth Alpha
const _waterDepth:float = 4.0;
const _valueThresh:float = 1.0 / _waterDepth;

var _terrain_data:Array[Map_Data.Terrain];
var _marking_data:Array[Map_Data.Marking];
var _buried_data:Array[int];

var _array_islands:Array[Array];
var _array_mountainRanges:Array[Array];

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
#@onready var _cont_showOnProximity:Node2D = $show_on_proximity;

@onready var _terrain_grouper:Node = $terrain_grouper;

@export_group("#DEBUG")
@export var _debug:bool;

signal Map_Generated;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	World.Replace_Terrain.connect(_On_Replace_Terrain_Sprite);
	
	# Make sure Zoom Objects start off Invisible
	_cont_showOnZoom.modulate.a = 0;
	
	#_Generate_Map(2989861102);


func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Cancel"):
		
		_Clear();
		
		var newSeed:int = randi();
		print("map_generator, Latest Seed: ", newSeed);
		_Generate_Map(newSeed);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Generate_Map(newSeed:int, callerPath:String) -> void:
	if _debug: print("\nmap_generator => Generate_map() called by: ", callerPath);
	_Generate_Map(newSeed);

func _Generate_Map(newSeed:int) -> void:
	
	_noiseTex.texture.noise.seed = newSeed;
	await _noiseTex.texture.changed;
	var noiseData:PackedByteArray = _noiseTex.get_texture().get_image().get_data();
	
	World.Set_MapWidth_In_Units(_noiseTex.get_texture().get_size().x, self.get_path());
	
	# Generate Map Data
	_terrain_data = Map_Data.Derive_TerrainData_From_NoiseData(_mountain, _forest, _ground, _shore, _shallow, _sea, _ocean, _depths, noiseData);
	
	# Derive Islands
	var islands_coordArrays:Array[Array] = _terrain_grouper.Island_CoordArrays_From_TerrainData(_terrain_data, self.get_path());
	# Convert Island Array[Array[Coord]] => Array[Array[Index]]
	for coordArray in islands_coordArrays:
		_array_islands.push_back(World.Convert_CoordArray_To_IdxArray(coordArray));
	
	# Derive Mountain Ranges
	for island in _array_islands:
		var m_cluster_array:Array[Array] = _terrain_grouper.TerrainClusters_From_Island(Map_Data.Terrain.MOUNTAIN, island, _terrain_data);
		for cluster in m_cluster_array:
			if cluster.size() > 9:
				_array_mountainRanges.push_back(cluster);
	
	var edgeRing_array:Array[Array];
	
	for m_range in _array_mountainRanges:
		
		var edge_ring:Array[int] = _TerrainCluster_Edges_FourDir(Map_Data.Terrain.MOUNTAIN, m_range);
		
		if edge_ring.size() > 0:
			edgeRing_array.push_back(edge_ring);
	
	for edgeIndices in edgeRing_array:
		_terrain_data[edgeIndices.pick_random()] = Map_Data.Terrain.MOUNTAIN_PATH;
	
	# Add Docks
	#_terrain_data = Map_Data.Amend_TerrainData_Docks(_terrain_data);
	_marking_data = Map_Data.Derive_MarkingData_From_TerrainData(_terrain_data);
	# Amend Map Data
	_terrain_data = Map_Data.Amend_TerrainData_Using_MarkingData(_terrain_data, _marking_data);
	#_marking_data = Map_Data.Amend_MarkingData_Houses(_marking_data);
	
	#for island in _array_islands:
		#for idx in island:
			#_terrain_data[idx] = Map_Data.Terrain.Null;
	
	#for island in _islands:
		#for idx in island:
			#_terrain_data[idx] = Map_Data.Terrain.HOLE;
	
	#var second_largest:Array[int];
	#
	#var top:int = 0;
	#var sub:int = 0;
	#
	#for island in _islands:
		#
		#if top == 0:
			#top = island.size();
			#
		#elif island.size() > top:
			#
			#sub = top;
			#second_largest = island;
			#top = island.size();
			#
		#elif island.size() > sub:
			#
			#sub = island.size();
			#second_largest = island;
#
	#for idx in second_largest:
		#match _terrain_data[idx]:
			#Map_Data.Terrain.MOUNTAIN:
				#_terrain_data[idx] = Map_Data.Terrain.COAST;
			#Map_Data.Terrain.HIGHLAND:
				#_terrain_data[idx] = Map_Data.Terrain.WATER_COAST;
			#Map_Data.Terrain.GROUND:
				#_terrain_data[idx] = Map_Data.Terrain.SEA;
			#Map_Data.Terrain.COAST:
				#_terrain_data[idx] = Map_Data.Terrain.SEA;
			#Map_Data.Terrain.SHALLOWS:
				#_terrain_data[idx] = Map_Data.Terrain.DEPTHS;
	
	# Create Sprite2Ds
	_sprite_array_Terrain = _TerrainSprites_From_TerrainData(_terrain_data);
	_sprite_array_Marking = _MarkingSprites_From_MarkingData(_marking_data);
	_sprite_array_Detail = _DetailSprites_From_MarkingData(_marking_data);
	
	# Buried Treasure
	for t in _terrain_data:
		
		if t == Map_Data.Terrain.SHORE || t == Map_Data.Terrain.GROUND || t == Map_Data.Terrain.FOREST:
			
			if randf_range(0, 1000) > 800:
				_buried_data.push_back(1);
			else:
				_buried_data.push_back(-1);
				
		else:
			_buried_data.push_back(-1);
	
	#for m_range in _array_mountainRanges:
		#var col:Color = Color(randf_range(.25, 1), randf_range(.25, 1), randf_range(.25, 1));
		#for idx in m_range:
			#_sprite_array_Terrain[idx].modulate = col;
			
	Map_Generated.emit();


func _Clear() -> void:
	# Delete Sprite2Ds
	for c in _cont_terrainSprites.get_children(): c.queue_free();
	
	# Clear all Sprite2D except the Player.
	# We put the Player in this Container for Y-Sorting.
	for c in _cont_showOnZoom.get_children():
		if c.name == "Player":
			continue;
		c.queue_free();
	
	for c in _cont_hideOnZoom.get_children(): c.queue_free();
	for c in _cont_alwaysShow.get_children(): c.queue_free();
	for c in _cont_treasures.get_children(): c.queue_free();
	# Delete Sprite2D References
	_sprite_array_Terrain = [];
	_sprite_array_Marking = [];
	_sprite_array_Detail = [];
	# Clear Data
	_array_islands = [];
	_array_mountainRanges = [];
	_buried_data = [];


# Functions: Create Sprites ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _TerrainSprites_From_TerrainData(terrainData:Array[Map_Data.Terrain]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for t in terrainData:
		
		#if t == Map_Data.Terrain.ABYSS:
			#s_array.append(null);
		#else:
		# Create Sprite
		var spr:Sprite2D = World.Create_Sprite(0, 0);
		_cont_terrainSprites.add_child(spr);
		
		_Configure_TerrainSprite_LandAndSea(spr, t);
		
		# Position Terrain Sprite
		
		spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
		spr.position += Vector2.ONE * randf_range(-.4, .4);
		spr.rotation += randf_range(-.0625, .0625);
		
		s_array.append(spr);
		
		# Set Next sprite Position
		
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
	
	if _debug: print_debug("_TerrainSprites_From_TerrainData, Terrain: ", s_array.size());
	return s_array;


func _MarkingSprites_From_MarkingData(markingData:Array[Map_Data.Marking]) -> Array[Sprite2D]:
	
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
				#s_array.append(null);
				
			#Map_Data.Marking.TENT:
				#spr = World.Create_Sprite(4, 9, 1, _glyphs);
				#_cont_showOnZoom.add_child(spr);
				#spr.modulate = Color.BLACK;
			
			Map_Data.Marking.STEPS:
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
				#spr.scale /= 1.5;
				#s_array.append(null);
				
			Map_Data.Marking.TREE:
				spr = World.Create_Sprite(7, 6);
				_cont_showOnZoom.add_child(spr);
				#spr.scale.x *= randf_range(.9, 1.125);
				spr.scale.y *= randf_range(.9, 1.125);
				spr.rotation += randf_range(-.125, .125);
			
			#Map_Data.Marking.TREE_HOUSE:
				## Same as TREE
				#spr = World.Create_Sprite(7, 6);
				#_cont_showOnZoom.add_child(spr);
				##spr.scale.x *= randf_range(.9, 1.125);
				#spr.scale.y *= randf_range(.9, 1.125);
				#spr.rotation += randf_range(-.125, .125);
				
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
				
			#Map_Data.Marking.WHALE:
				#spr = World.Create_Sprite(2, 5, 1, _glyphs);
				#_cont_showOnZoom.add_child(spr);
			
			#Map_Data.Marking.HOT_AIR_BALLOON:
				#spr = World.Create_Sprite(10, 5);
				#_cont_treasures.add_child(spr);
			
			Map_Data.Marking.SEAGRASS:
				spr = World.Create_Sprite(0, 5);
				_cont_showOnZoom.add_child(spr);
				spr.rotation_degrees = 90;
				spr.modulate.a = randf_range(.125, .25);
			
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
			
	if _debug: print_debug("_MarkingSprites_From_MarkingData, Markings: ", s_array.size());
	return s_array;


func _DetailSprites_From_MarkingData(markingData:Array[Map_Data.Marking]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for m_idx in markingData.size():
		
		var spr:Sprite2D = null;
		
		match markingData[m_idx]:
		
			Map_Data.Marking.HOUSE:
				
				spr = World.Create_Sprite(randi_range(2, 4), 14);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				# Randomise Transform
				spr.position.y = currY * World.CellSize - randf_range(World.CellSize / 3, World.CellSize / 2);
				spr.scale *= randf_range(1, 1.125);
				#spr.scale *= 0.75;
				spr.rotation += randf_range(-.125, .125);
				
				spr.modulate.a = 0;
				
			Map_Data.Marking.STEPS:
				spr = World.Create_Sprite(1, 3, 1, _glyphs);
				_cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.modulate = Color.BLACK;
				
				spr.modulate.a = 0;
				#spr.offset = _sprite_array_Terrain[m_idx].offset;
				
			#Map_Data.Marking.TENT:
				#pass;
				
			Map_Data.Marking.PEAK:
				spr = World.Create_Sprite(3, 6);
				_cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.scale *= 1.5;
				#spr.rotation += randf_range(-.125, .125);
				
			Map_Data.Marking.MINI_MOUNT:
				pass;
				
			Map_Data.Marking.HILL:
				#spr = World.Create_Sprite(5, 7);
				#_cont_showOnZoom.add_child(spr);
				#spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				## Randomise Transform
				##spr.position.y = currY * World.CellSize - randf_range(0, World.CellSize / 2);
				#spr.scale *= randf_range(1, 1.125);
				##spr.scale /= 1.5;
				#spr.rotation += randf_range(-.125, .125);
				pass;
				
			Map_Data.Marking.TREE:
				pass;
				
				#spr = World.Create_Sprite(8, 6);
				#_cont_showOnZoom.add_child(spr);
				#
				#spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				## Randomise Transform
				#spr.position += Vector2.ONE * randf_range(-.4, .4);
				#spr.scale += Vector2.ONE * randf_range(-.01, .02);
				#spr.offset.y -= World.CellSize * 4;
			
			#Map_Data.Marking.TREE_HOUSE:
				## Same as HOUSE
				#spr = World.Create_Sprite(randi_range(2, 4), 14);
				#_cont_showOnZoom.add_child(spr);
				#
				#spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				## Randomise Transform
				#spr.position.y = currY * World.CellSize - randf_range(0, World.CellSize * .5);
				##spr.scale *= randf_range(1, 1.125);
				#spr.scale *= 0.75;
				#spr.rotation += randf_range(-.125, .125);
				#
				#spr.modulate.a = 0;
				
			Map_Data.Marking.LIGHTHOUSE:
				
				#spr = World.Create_Sprite(14, 5);
				#spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size * 2);
				#spr.offset.y -= World.Spr_Reg_Size;
				
				spr = World.Create_Sprite(7, 12, 2);
				_cont_showOnZoom.add_child(spr);
				
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.position.y -= World.CellSize / 2;
				# Adjust Sprite2D
				#spr.region_rect.size = Vector2(World.Spr_Reg_Size, World.Spr_Reg_Size * 2);
				#spr.offset.y -= World.Spr_Reg_Size / 4 * 3;
				#spr.scale /= 2;
				
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
				
				spr = World.Create_Sprite(2, 7);
				_cont_showOnZoom.add_child(spr);
				
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
				_cont_showOnZoom.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
				spr.modulate = Color.BLACK;
			
			Map_Data.Marking.SEAGRASS:
				pass;
			
			Map_Data.Marking.BOAT:
				pass;
				
			Map_Data.Marking.Null:
				pass;
			
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Map_Data.Marking.find_key(markingData[m_idx]));
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
			
	if _debug: print_debug("_DetailSprites_From_MarkingData, Details: ", s_array.size());
	return s_array;


#func Create_Sprite(regPosX:float, regPosY:float, callerPath:String) -> Sprite2D:
	#if _debug: print("\nmap_generator.gd - Create_Sprite, called by: ", callerPath);
	#return World.Create_Sprite(regPosX, regPosY);


func _Configure_TerrainSprite_LandAndSea(spr:Sprite2D, terrainType:Map_Data.Terrain) -> void:
	
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


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _TerrainCluster_Edges_FourDir(type:Map_Data.Terrain, cluster:Array[int]) -> Array[int]:
	var edges:Array[int];
	#
	for i in cluster.size():
		
		var rocks:int;
		var curr_coord:Vector2 = World.Convert_Index_To_Coord(cluster[i]);
		
		var up_coord:Vector2 = curr_coord + Vector2.UP * World.CellSize;
		if up_coord.y <= World.CellSize:
			continue;
		if _terrain_data[World.Convert_Coord_To_Index(up_coord)] == Map_Data.Terrain.MOUNTAIN:
			rocks += 1;
			
		var down_coord:Vector2 = curr_coord + Vector2.DOWN * World.CellSize;
		if down_coord.y >= World.MapWidth_In_Units() * World.CellSize - World.CellSize:
			continue;
		if _terrain_data[World.Convert_Coord_To_Index(down_coord)] == Map_Data.Terrain.MOUNTAIN:
			rocks += 1;
		
		var left_coord:Vector2 = curr_coord + Vector2.LEFT * World.CellSize;
		if left_coord.x <= World.CellSize:
			continue;
		if _terrain_data[World.Convert_Coord_To_Index(left_coord)] == Map_Data.Terrain.MOUNTAIN:
			rocks += 1;
			
		var right_coord:Vector2 = curr_coord + Vector2.RIGHT * World.CellSize;
		if right_coord.x >= World.MapWidth_In_Units() * World.CellSize - World.CellSize:
			continue;
		if _terrain_data[World.Convert_Coord_To_Index(right_coord)] == Map_Data.Terrain.MOUNTAIN:
			rocks += 1;
		
		if rocks > 0 && rocks < 4:
			edges.push_back(cluster[i]);
	
	return edges;


func _Get_All_Cells_Of_TerrainType_On_Island(type:Map_Data.Terrain, island_idxArray:Array[int], terrainData:Array[Map_Data.Terrain]) -> Array[int]:
	var t_group:Array[int];
	
	for idx in island_idxArray:
		if terrainData[idx] == type:
			t_group.push_back(idx);
	
	return t_group;


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_TerrainSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print("\nmap_generator.gd - Get_TerrainSprite, called by: ", callerPath);
	return _sprite_array_Terrain[World.Convert_Coord_To_Index(coord)];
	
func Get_MarkingSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print("\nmap_generator.gd - Get_MarkingSprite, called by: ", callerPath);
	return _sprite_array_Marking[World.Convert_Coord_To_Index(coord)];
	
func Get_DetailSprite(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print("\nmap_generator.gd - Get_DetailSprite, called by: ", callerPath);
	return _sprite_array_Detail[World.Convert_Coord_To_Index(coord)];


func Get_Terrain(idx:int, callerPath:String) -> Map_Data.Terrain:
	if _debug: print("\nmap_generator.gd - Get_TerrainType, called by: ", callerPath);
	return _terrain_data[idx];

func Get_Marking(idx:int, callerPath:String) -> Map_Data.Marking:
	if _debug: print("\nmap_generator.gd - Get_Marking, called by: ", callerPath);
	return _marking_data[idx];

func Get_Buried(idx:int, callerPath:String) -> int:
	if _debug: print("\nmap_generator.gd - Get_Marking, called by: ", callerPath);
	return _buried_data[idx];


#func Is_Land(coord:Vector2, callerPath:String, idx:int = -1) -> bool:
	#if _debug: print("\nmap_generator.gd - Is_Land, called by: ", callerPath);
	#return _Is_Land(coord, idx);
#
#func _Is_Land(coord:Vector2, idx:int = -1) -> bool:
	#
	#var t:Map_Data.Terrain;
	#
	#if idx == -1:
		#t = _terrain_data[World.Convert_Coord_To_Index(coord)];
	#else:
		#t = _terrain_data[idx];
	#
	#if t == Map_Data.Terrain.MOUNTAIN \
	#|| t == Map_Data.Terrain.MOUNTAIN_PATH \
	#|| t == Map_Data.Terrain.FOREST \
	#|| t == Map_Data.Terrain.GROUND \
	#|| t == Map_Data.Terrain.SHORE \
	#|| t == Map_Data.Terrain.TEMPLE_BROWN \
	#|| t == Map_Data.Terrain.DOCK:
		#return true;
	#return false;


func ChangeTerrain(v2_array:Array[Vector2], terrainType:Map_Data.Terrain, callerPath:String) -> void:
	if _debug: print_debug("\nmap_generator.gd - ChangeTerrain, called by: ", callerPath);
	_ChangeTerrain(v2_array, terrainType);

func _ChangeTerrain(v2_array:Array[Vector2], terrainType:Map_Data.Terrain) -> void:
	for v2 in v2_array:
		var spr:Sprite2D = _sprite_array_Terrain[World.Convert_Coord_To_Index(v2)];
		_Configure_TerrainSprite_LandAndSea(spr, terrainType);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _On_Replace_Terrain_Sprite(idx:int, type:Map_Data.Terrain, spr:Sprite2D) -> void:
	_terrain_data[idx] = type;
	if spr:
		_sprite_array_Terrain[idx] = spr;
