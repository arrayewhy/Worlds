class_name Map_Data

enum Terrain {
	Null, # 0
	
	#DEBUG
	HOLE,
	
	# Land
	MOUNTAIN,
	#MOUNTAIN_PATH,
	FOREST,
	GROUND,
	SHORE,
	# Water
	SHALLOW,
	SEA,
	OCEAN,
	DEPTHS,
	ABYSS,
	
	# Special: Land
	TEMPLE_BROWN,
	#DOCK,
	# Special: Water
	#SEA_GREEN,
	#WATER_COAST,
	}

enum Marking { 
	Null, # 0
	HOUSE,
	OLD_HOUSE,
	FOREST_FIRE,
	#TENT,
	PEAK,
	HILL,
	GRASS,
	TREE,
	LIGHTHOUSE, # 5
	SHELL,
	SMALL_FISH,
	BIG_FISH,
	JETTY,
	TREASURE,
	#WHALE,
	#HOT_AIR_BALLOON,
	OARFISH,
	#SEAGRASS,
	TEMPLE,
	GOLD,
	MESSAGE_BOTTLE,
	MINI_MOUNT,
	HOBBIT_HOUSE,
	MOUNTAIN_ENTRANCE,
	BOAT,
	SHIP,
	#TREE_HOUSE,
	DRAGON,
	}

#enum Secrets {
	#Null,
	#DRAGON,
#}

static var Terrain_Colours:Dictionary[Terrain, Array] = {
				Terrain.Null : [ 255, 0, 255, 255 ],
			#DEBUG
				Terrain.HOLE : [ 200, 100, 0, 255 ],
			# Land
				Terrain.MOUNTAIN : [ 170, 170, 170, 255 ],
				#Terrain.MOUNTAIN_PATH : [ 220, 220, 200, 255 ],
				Terrain.FOREST : [ 70, 130, 90, 255 ],
				Terrain.GROUND : [ 110, 170, 110, 255 ],
				Terrain.SHORE : [ 210, 210, 150, 255 ],
			# Water
				Terrain.SHALLOW : [ 100, 180, 190, 255 ],
				Terrain.SEA : [ 70, 140, 160, 255 ],
				Terrain.OCEAN : [ 50, 100, 120, 255 ],
				Terrain.DEPTHS : [ 30, 60, 80, 255 ],
				Terrain.ABYSS : [ 20, 30, 60, 255 ],
			# Special: Land
				Terrain.TEMPLE_BROWN : [ 210, 60, 0, 255 ],
}

const goodSeeds:Dictionary[int, String] = {
	3184197067 : "",
	3043322721 : "",
	3879980289 : "",
	3302025460 : "",
	3869609850 : "",
	3622769036 : "",
	3726595959 : "three_brothers",
	278936286 : "",
	462604253 : "broken_bridge",
	1504345747 : "jurassic",
	1852288905 : "the_argument",
	920171824 : "",
	2219318034 : "cut_through_the_mountains",
	2912471184 : "",
	1970006309 : "leviathan",
	429314510 : "",
	787546645 : "big_boy",
	3790769020 : "the_howl",
	2239492294 : "",
	2989861102 : "",
	1223885537 : "",
	652673025 : "lakes",
	1300341631 : "",
	1840541886: "",
	};

#var _messageBottle_spawned:bool;

static var _boat_spawned:bool;


# Terrain ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


static func Derive_TerrainData_From_NoiseData(
	mountain:float, forest:float, ground:float, shore:float, 
	shallow:float, sea:float, ocean:float, depths:float, 
	noiseData:Array) -> Array[Terrain]:
	
	var t:Array[Terrain];
	
	for d in noiseData:
		if d >= mountain:
			t.append(Terrain.MOUNTAIN);
			continue;
		elif d >= forest && d < mountain:
			t.append(Terrain.FOREST);
			continue;
		elif d >= ground && d < forest:
			t.append(Terrain.GROUND);
			continue;
		elif d >= shore && d < ground:
			t.append(Terrain.SHORE);
			continue;
		elif d >= shallow && d < shore:
			t.append(Terrain.SHALLOW);
			continue;
		elif d >= sea && d < shallow:
			t.append(Terrain.SEA);
			continue;
		elif d >= ocean && d < sea:
			t.append(Terrain.OCEAN);
			continue;
		elif d >= depths && d < ocean:
			t.append(Terrain.DEPTHS);
			continue;
		elif d < depths:
			t.append(Terrain.ABYSS)
			continue;
		else:
			print_debug("Noise Data Unaccounted for: ", d);
	
	return t;

static func Derive_TerrainData_From_ImgData(img:Texture2D, has_alpha:bool) -> Array[Terrain]:
	
	var colours:Array[Array] = Tools.Colours_From_Tex2D(img, has_alpha);
	
	var t_array:Array[Terrain];
	
	for col in colours:
		t_array.append(Terrain_Colours.find_key(col));
		
	return t_array;

static func Amend_TerrainData_Using_MarkingData(terrainData:Array[Terrain], markingData:Array[Marking]) -> Array[Terrain]:
	
	var t:Array[Terrain] = terrainData;
	
	for i in markingData.size():
		match markingData[i]:
			Marking.TEMPLE:
				t[i] = Terrain.TEMPLE_BROWN;
				
	return t;


# Marking ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


static func Derive_MarkingData_From_TerrainData(terrainData:Array[Terrain]) -> Array[Marking]:
	
	var m:Array[Marking];
	
	for t in terrainData:
		
		match t:
			
			Terrain.Null:
				m.append(Marking.Null);
			
			Terrain.MOUNTAIN:
				#if randi_range(0, 1000) > 999:
					#m.append(Marking.HOUSE);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				#if randi_range(0, 1000) > 900:
					#m.append(Marking.PEAK);
				if randi_range(0, 1000) > 200:
					m.append(Marking.MINI_MOUNT);
				#elif randi_range(0, 1000) > 990:
					#m.append(Marking.HOT_AIR_BALLOON);
				else:
					m.append(Marking.Null);
				#m.append(Marking.Null);
				continue;
			
			#Terrain.MOUNTAIN_PATH:
				#m.append(Marking.MOUNTAIN_ENTRANCE);
				#m.append(Marking.Null);
				#continue;
			
			Terrain.FOREST:
				#if randi_range(0, 1000) > 500:
					#m.append(Marking.HILL);
				if randi_range(0, 1000) > 50:
					m.append(Marking.TREE);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				#elif randi_range(0, 1000) > 50:
					#m.append(Marking.TREE_HOUSE);
				elif randi_range(0, 1000) > 50:
					m.append(Marking.HILL);
				elif randi_range(0, 1000) > 200:
					m.append(Marking.HOBBIT_HOUSE);
				#elif randi_range(0, 1000) > 100:
					#m.append(Marking.HOUSE);
				else:
					m.append(Marking.TEMPLE);
					#m.append(Marking.Null);
				continue;
			
			Terrain.GROUND:
				if randi_range(0, 1000) > 600:
					m.append(Marking.TREE);
				#elif randi_range(0, 1000) > 900:
					#m.append(Marking.HOUSE);
				#elif randi_range(0, 1000) > 998:
					#m.append(Marking.TEMPLE);
				else:
					m.append(Marking.GRASS);
				continue;
				
			Terrain.SHORE:
				#if randi_range(0, 1000) > 990:
					#m.append(Marking.LIGHTHOUSE);
				if randi_range(0, 1000) > 990:
					m.append(Marking.SHELL);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.SHALLOW:
				#if !_boat_spawned:
					#m.append(_Boat_Marking());
				#else:
				m.append(Marking.Null);
				continue;
				
			Terrain.SEA:
				if randi_range(0, 1000) > 960:
					m.append(Marking.SMALL_FISH);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.JETTY);
				#elif randf_range(0, 1000) > 990:
					#m.append(Marking.SHIP);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.OCEAN:
				#if randi_range(0, 1000) > 700:
					#m.append(Marking.SEAGRASS);
				if randf_range(0, 1000) > 990:
					m.append(Marking.SHIP);
				#if randi_range(0, 1000) > 990:
					#m.append(Marking.BIG_FISH);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.GOLD);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.DEPTHS: # SAME
				if randi_range(0, 1000) > 980:
					m.append(Marking.GOLD);
				elif randi_range(0, 1000) > 999:
					m.append(Marking.MESSAGE_BOTTLE);
				elif randf_range(0, 1000) > 980:
					m.append(Marking.SHIP);
				else:
					m.append(Marking.Null);
				continue;
			
			Terrain.ABYSS: # SAME
				if randf_range(0, 1000) > 997:
					m.append(Marking.TREASURE);
				#elif randf_range(0, 1000) > 996:
					#m.append(Marking.WHALE);
				else:
					m.append(Marking.Null);
				continue;
				
			# Specials
			#Terrain.SEA_GREEN:
				#m.append(Marking.Null);
				#continue;
			Terrain.TEMPLE_BROWN:
				m.append(Marking.Null);
				continue;
			#Terrain.DOCK:
				#m.append(Marking.Null);
				#continue;
				
			Terrain.HOLE:
				m.append(Marking.Null);
				continue;
				
			_:
				print_debug("\nMarking Data contains Invalid Data: ", Terrain.keys()[t]);
				continue;
			
	return m;

static func Derive_MarkingData_From_ImgData(img:Texture2D, has_alpha:bool) -> Array[Marking]:
	
	var colours:Array[Array] = Tools.Colours_From_Tex2D(img, has_alpha);
	
	var m_array:Array[Marking];
	
	for col in colours:
		
		match col:
			[225, 135, 0, 255]:
				m_array.append(Marking.OLD_HOUSE);
			
			_:
				m_array.append(Marking.Null);
				
	return m_array;

static func Override_MarkingData_with_ImageData(m_data:Array[Marking], img:Texture2D, has_alpha:bool) -> Array[Marking]:
	
	var new_m_data:Array[Marking] = m_data;
	
	var colours:Array[Array] = Tools.Colours_From_Tex2D(img, has_alpha);
	
	assert(new_m_data.size() == colours.size(), "Marking data Size does NOT match Marking Map colour Array Size.");
	
	for c in colours.size():
		match colours[c]:
			[225, 135, 0, 255]:
				new_m_data[c] = Marking.LIGHTHOUSE;
			[185, 85, 0, 255]:
				new_m_data[c] = Marking.BOAT;
			[225, 55, 0, 255]:
				new_m_data[c] = Marking.OLD_HOUSE;
			[115, 195, 205, 255]:
				new_m_data[c] = Marking.FOREST_FIRE;
	
	return new_m_data;


static func Amend_MarkingData_Houses(markingData:Array[Marking]) -> Array[Marking]:
	
	var m_array:Array[Marking] = markingData;
	
	#var width:float = World.MAP_UNIT_WIDTH;
	
	for i in m_array.size():
		
		match m_array[i]:
			
			Marking.TREE:
				
				var center:Vector2 = Tools.Convert_Index_To_Coord(i);
				
				var surr_coords:Array[Vector2] = Tools.V2_Array_Around(center, 1, true);
				
				var trees:int = 0;
				
				for coord in surr_coords:
					if m_array[Tools.Convert_Coord_To_Index(coord)] == Marking.TREE:
						trees += 1;

				if trees >= 8:
					m_array[i] = Marking.HOUSE;
				
	return m_array;


#static func Amend_TerrainData_Docks(terrainData:Array[Terrain]) -> Array[Terrain]:
	#
	##TEMPORARY
	##var done = false;
	#
	#var t_array:Array[Terrain] = terrainData;
	#
	#for t_idx in t_array.size():
		#
		#match t_array[t_idx]:
			#
			#Terrain.SHORE:
			#
				#if randf_range(0, 1000) < 990:
					#continue;
				#
				##TEMPORARY
				##if !done:
					##done = true;
					#
				#var start:Vector2 = Tools.Convert_Index_To_Coord(t_idx);
				#
				#var dockTarget:Vector2 = -Vector2.ONE;
				#var dockIdx:int = 0;
				#
				#var highest_waterScore:int = 0;
				#
				#var directions:Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT];
				#
				#for d in directions:
#
					#var check_center:Vector2i = start + World.CellSize * 5 * d;
					#
					#var surr_coords:Array[Vector2] = Tools.V2_Array_Around(check_center, 4);
							#
					#var surr_indices:Array[int];
					#for c_index in surr_coords.size():
						#surr_indices.append(Tools.Convert_Coord_To_Index(surr_coords[c_index]));
					#
					#var score:int = 0;
					#for index in surr_indices:
						#
						#if t_array[index] == Terrain.SEA \
						#|| t_array[index] == Terrain.OCEAN \
						#|| t_array[index] == Terrain.DEPTHS \
						#|| t_array[index] == Terrain.ABYSS:
						##|| t_array[index] == Terrain.SEA_GREEN:
							#score += 1;
						#else:
							#score -= 1;
					#
					##print(score);
					#
					#if score > highest_waterScore && check_center > Vector2i.ZERO:
						#highest_waterScore = score;
						#dockTarget = check_center;
				#
				##t_array[Tools.Convert_Coord_To_Index(start)] = Terrain.Null;
				#
				#if highest_waterScore > 20:
#
					#if dockTarget != -Vector2.ONE:
						#
						##t_array[Tools.Convert_Coord_To_Index(dockTarget)] = Terrain.HOLE;
						#
						#var dist:float = start.distance_to(dockTarget) / World.CellSize;
						#
						#var dir = (dockTarget - start).normalized() * World.CellSize;
						#
						#var currCoord:Vector2 = start;
						#
						#for d in dist:
							#
							#currCoord += dir;
							#
							#if t_array[Tools.Convert_Coord_To_Index(currCoord)] == Terrain.DOCK:
								##print("Short Dock");
								#break;
							#
							#t_array[Tools.Convert_Coord_To_Index(currCoord)] = Terrain.DOCK;
						##print("Full Dock");
						##var next:Vector2 = start + dir;
	#
	#return t_array;


# Secret ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


#static func Derive_SecretData_From_MarkingData(markingData:Array[Marking]) -> Array[Secrets]:
	#
	#var s:Array[Secrets];
	#
	#for m in markingData:
		#
		#match m:
			#
			#Marking.PEAK:
				#if randf_range(0, 1) > .9:
					#s.append(Secrets.DRAGON);
				#else:
					#s.append(Secrets.Null);
			#
			#_:
				#s.append(Secrets.Null);
	#
	#return s;


# Others ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


static func _Boat_Marking() -> Marking:
	if _boat_spawned: printerr("Duplicate Marking: Marking.BOAT");
	_boat_spawned = true;
	return Marking.BOAT;
