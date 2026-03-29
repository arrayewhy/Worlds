extends Node2D

# Resources
const _glyphs:Texture2D = preload("res://Sprites/Glyphs.png");
const _terrain_sprites:Texture2D = preload("res://Sprites/terrain_sprites.png");

const _fadeInOut:Shader = preload("res://Shaders/fadeInOut.gdshader");
const _wiggle:Shader = preload("res://Shaders/wiggle.gdshader");

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
var _secret_data:Array[Map_Data.Secrets];
var _buried_data:Array[int];

var _array_islands:Array[Array];
var _array_mountainRanges:Array[Array];

# Sprite2D Arrays to quickly grab a Sprite2D by its Index
var _sprite_array_Terrain:Array[Sprite2D];
var _sprite_array_Marking:Array[Sprite2D]; # Markings / NULL
var _sprite_array_Detail:Array[Sprite2D]; # Details / NULL
var _sprite_array_Secrets:Array[Sprite2D]; # Secrets / NULL

# Noise Data
@export var _noiseTex:TextureRect;

# Sprite2D Containers
@onready var _cont_terrainSprites:Node2D = $terrain;
@onready var _cont_showOnZoom:Node2D = $show_on_zoom;
@onready var _cont_hideOnZoom:Node2D = $hide_on_zoom;
@onready var _cont_alwaysShow:Node2D = $always_show;
@onready var _cont_treasures:CanvasLayer = $treasures;
@onready var _cont_secrets:Node2D = $secrets;
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


func _process(delta: float) -> void:
	
	if !Input.is_action_pressed("Cancel") || !Input.is_action_just_pressed("Enter"):
		return;
			
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
	
	# Largest Island - START * * * * *
	
	var largest_island:int;
	
	for i in _array_islands.size():
		if _array_islands[i].size() > _array_islands[largest_island].size():
			largest_island = i;
	
	# Make Other islands water
	
	for i in _array_islands.size():
		if i == largest_island:
			continue;
		else:
			for idx in _array_islands[i]:
				_terrain_data[idx] = Map_Data.Terrain.SHALLOW;
	
	# END
	
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
	
	_marking_data = Map_Data.Derive_MarkingData_From_TerrainData(_terrain_data);
	# Amend Map Data
	_terrain_data = Map_Data.Amend_TerrainData_Using_MarkingData(_terrain_data, _marking_data);
	#_marking_data = Map_Data.Amend_MarkingData_Houses(_marking_data);
	_secret_data = Map_Data.Derive_SecretData_From_MarkingData(_marking_data);
	
	# Add Docks
	#_terrain_data = Map_Data.Amend_TerrainData_Docks(_terrain_data);
	
	# Mark Lighthouse - START * * * * *
	
	var lighthouse_spawned:bool;
	
	for i in _array_islands[largest_island].size():
		
		var idx:int = _array_islands[largest_island][i];
		
		if _terrain_data[idx] == Map_Data.Terrain.SHORE && randf_range(0, 1000) > 995:
			_marking_data[idx] = Map_Data.Marking.LIGHTHOUSE;
			lighthouse_spawned = true;
			break;
		else:
			continue;
	
	if !lighthouse_spawned:
		
		for i in _array_islands[largest_island].size():
			
			var idx:int = _array_islands[largest_island][i];
			
			if _terrain_data[idx] == Map_Data.Terrain.SHORE:
				_marking_data[idx] = Map_Data.Marking.LIGHTHOUSE;
				break;
	
	# Create Sprite2Ds
	_sprite_array_Terrain = _TerrainSprites_From_TerrainData(_terrain_data);
	
	_sprite_array_Marking = $sprite_handler._MarkingSprites_From_MarkingData(
		_marking_data, \
		_cont_showOnZoom, \
		_cont_hideOnZoom, \
		_cont_alwaysShow, \
		_cont_treasures, \
		_debug
		);
		
	_sprite_array_Detail = _DetailSprites_From_MarkingData(_marking_data);
	_sprite_array_Secrets = _SecretSprites_From_SecretData(_secret_data);
	
	
	# Buried Treasure
	_Create_Buried_Treasure();
	
	Map_Generated.emit();


func _Create_Buried_Treasure() -> void:
	for t in _terrain_data:
		
		if t == Map_Data.Terrain.SHORE:
			
			if randf_range(0, 1000) > 800:
				# Append with the ID of the Treasure Type
				_buried_data.push_back(1);
			else:
				_buried_data.push_back(-1);
				
		else:
			_buried_data.push_back(-1);


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
		
		var spr:Sprite2D = World.Create_Sprite(0, 0, 1, _terrain_sprites);
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
				
			Map_Data.Marking.MOUNTAIN_ENTRANCE:
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
				spr.name = "Peak";
				
			Map_Data.Marking.MINI_MOUNT:
				pass;
				
			Map_Data.Marking.HILL:
				pass;
				
			Map_Data.Marking.TREE:
				pass;
				
			Map_Data.Marking.LIGHTHOUSE:
				
				spr = World.Create_Sprite(7, 12, 2);
				_cont_showOnZoom.add_child(spr);
				
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
			
			#Map_Data.Marking.SEAGRASS:
				#pass;
			
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


func _SecretSprites_From_SecretData(secretData:Array[Map_Data.Secrets]) -> Array[Sprite2D]:
	
	var s_array:Array[Sprite2D];
	
	var currX:int = 0;
	var currY:int = 0;
	
	for s_idx in secretData.size():
		
		var spr:Sprite2D = null;
		
		match secretData[s_idx]:
			
			Map_Data.Secrets.DRAGON:
				spr = World.Create_Sprite(9, 1);
				_cont_secrets.add_child(spr);
				spr.position = Vector2(currX * World.CellSize, currY * World.CellSize);
			
			_:
				pass;
		
		if spr:
			spr.modulate.a = 0;
		
		s_array.append(spr);
		
		# Set Next Detail Position
		currX += 1;
		if currX >= World.MapWidth_In_Units():
			currX = 0;
			currY += 1;
		
	if _debug: print_debug("_SecretSprites_From_SecretData, Secrets: ", s_array.size());
	return s_array;


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
	if World.Convert_Coord_To_Index(coord) > _sprite_array_Terrain.size() - 1:
		return null;
	return _sprite_array_Terrain[World.Convert_Coord_To_Index(coord)];
	
func Get_Spr_Marking(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print("\nmap_generator.gd - Get_Spr_Marking, called by: ", callerPath);
	if World.Convert_Coord_To_Index(coord) > _sprite_array_Marking.size() - 1:
		return null;
	return _sprite_array_Marking[World.Convert_Coord_To_Index(coord)];
	
func Get_Spr_Detail(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print("\nmap_generator.gd - Get_Spr_Detail, called by: ", callerPath);
	if World.Convert_Coord_To_Index(coord) > _sprite_array_Detail.size() - 1:
		return null;
	return _sprite_array_Detail[World.Convert_Coord_To_Index(coord)];

func Get_Spr_Secret(coord:Vector2, callerPath:String) -> Sprite2D:
	if _debug: print("\nmap_generator.gd - Get_Spr_Secret, called by: ", callerPath);
	if World.Convert_Coord_To_Index(coord) > _sprite_array_Secrets.size() - 1:
		return null;
	return _sprite_array_Secrets[World.Convert_Coord_To_Index(coord)];


func Get_Terrain(idx:int, callerPath:String) -> Map_Data.Terrain:
	if _debug: print("\nmap_generator.gd - Get_TerrainType, called by: ", callerPath);
	return _terrain_data[idx];

func Get_Marking(idx:int, callerPath:String) -> Map_Data.Marking:
	if _debug: print("\nmap_generator.gd - Get_Marking, called by: ", callerPath);
	return _marking_data[idx];

func Get_Secret(idx:int, callerPath:String) -> Map_Data.Secrets:
	if _debug: print("\nmap_generator.gd - Get_Marking, called by: ", callerPath);
	return _secret_data[idx];

func Get_Buried(idx:int, callerPath:String) -> int:
	if _debug: print("\nmap_generator.gd - Get_Marking, called by: ", callerPath);
	return _buried_data[idx];


func Get_Terrain_Data(callerPath:String) -> Array[Map_Data.Terrain]:
	if _debug: print("\nmap_generator.gd - Get_Terrain_Data, called by: ", callerPath);
	return _terrain_data;


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
