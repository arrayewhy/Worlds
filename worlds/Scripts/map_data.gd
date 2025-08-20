class_name Map_Data

enum Terrain {
	Null, # 0
	MOUNTAIN,
	HIGHLAND,
	GROUND,
	COAST,
	SHALLOWS, # 5
	SEA,
	DEPTHS,
	ABYSS,
	# Specials
	SEA_GREEN,
	TEMPLE_BROWN,
	DOCK,
	#DEBUG
	DEBUG_HOLE,
	}

enum Marking { 
	Null, # 0
	HOUSE,
	#TENT,
	PEAK,
	HILL,
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
	SEAGRASS,
	TEMPLE,
	GOLD,
	MESSAGE_BOTTLE,
	}

#var _messageBottle_spawned:bool;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


static func Derive_TerrainData_From_NoiseData(mountain:float, highland:float, ground:float, coast:float, shallows:float, sea:float, depths:float, noiseData:Array) -> Array[Terrain]:
	
	var t:Array[Terrain];
	
	for d in noiseData:
		if d >= mountain:
			t.append(Terrain.MOUNTAIN);
			continue;
		elif d >= highland && d < mountain:
			t.append(Terrain.HIGHLAND);
			continue;
		elif d >= ground && d < highland:
			t.append(Terrain.GROUND);
			continue;
		elif d >= coast && d < ground:
			t.append(Terrain.COAST);
			continue;
		elif d >= shallows && d < coast:
			t.append(Terrain.SHALLOWS);
			continue;
		elif d >= sea && d < shallows:
			t.append(Terrain.SEA);
			continue;
		elif d >= depths && d < sea:
			t.append(Terrain.DEPTHS);
			continue;
		elif d < depths:
			t.append(Terrain.ABYSS)
			continue;
		else:
			print_debug("Noise Data Unaccounted for: ", d);
	
	return t;


static func Derive_MarkingData_From_TerrainData(terrainData:Array[Terrain]) -> Array[Marking]:
	
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
					m.append(Marking.HILL);
				continue;
			
			Terrain.HIGHLAND:
				if randi_range(0, 1000) > 500:
					m.append(Marking.TREE);
					#m.append(Marking.HILL);
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
				elif randi_range(0, 1000) > 999:
					m.append(Marking.MESSAGE_BOTTLE);
				else:
					m.append(Marking.Null);
				continue;
			
			Terrain.ABYSS:
				if randf_range(0, 1000) > 997:
					m.append(Marking.TREASURE);
				#elif randf_range(0, 1000) > 996:
					#m.append(Marking.WHALE);
				else:
					m.append(Marking.Null);
				continue;
				
			# Specials
			Terrain.SEA_GREEN:
				m.append(Marking.Null);
				continue;
			Terrain.TEMPLE_BROWN:
				m.append(Marking.Null);
				continue;
			Terrain.DEBUG_HOLE:
				m.append(Marking.Null);
				continue;
				
			_:
				print_debug("\nMarking Data contains Invalid Data");
				continue;
			
	return m;


static func Amend_TerrainData_Using_MarkingData(terrainData:Array[Terrain], markingData:Array[Marking]) -> Array[Terrain]:
	
	var t:Array[Terrain] = terrainData;
	
	for i in markingData.size():
		match markingData[i]:
			Marking.SEAGRASS:
				t[i] = Terrain.SEA_GREEN;
			Marking.TEMPLE:
				t[i] = Terrain.TEMPLE_BROWN;
				
	return t;


static func Amend_MarkingData(markingData:Array[Marking]) -> Array[Marking]:
	
	var mark_array:Array[Marking] = markingData;
	
	#var width:float = World.MapWidth();
	
	for i in mark_array.size():
		
		match mark_array[i]:
			
			Marking.TREE:
				
				var center:Vector2 = World.Index_To_Coord(i) * World.CellSize;
				
				#center = World.Coord_OnGrid(center);
				var surr_coords:Array[Vector2] = World.V2_Array_Around(center, 1, true);
				
				var surr_idx:Array[int] = [];
				
				for coord in surr_coords:
					surr_idx.append(World.Coord_To_Index(coord));

				var surr_marks:Array[Marking] = [];
				
				for idx in surr_idx:
					surr_marks.append(mark_array[idx]);
				
				var trees:int = 0;
				
				for m in surr_marks:
					if m == Marking.TREE:
						trees += 1;

				if trees >= 8:
					mark_array[i] = Marking.HOUSE;
				
	return mark_array;


static func Amend_TerrainData(terrainData:Array[Terrain]) -> Array[Terrain]:
	var done = false;
	var t_array:Array[Terrain] = terrainData;
	
	for t_idx in t_array.size():
		
		match t_array[t_idx]:
			
			Terrain.COAST:
			
				if randf_range(0, 1000) < 900:
					continue;
					
				if !done:
					done = true;
					
					var start:Vector2 = World.Index_To_Coord(t_idx);
					
					var dockTarget:Vector2 = -Vector2.ONE;
					var dockIdx:int = 0;
					
					var highest_waterScore:int = 0;
					
					var rows:int = 3;
					var cols:int = 3;
					var currIdx:int = 0;
					
					# START: Look for Suitable Dock Point
					for row in rows:
						
						for col in cols:
					
							var dir:Vector2 = Vector2(-1 + col, -1 + row);
					
							# Skip Center
							if dir == Vector2.ZERO:
								continue;
					
							var extension_center:Vector2 = start + World.CellSize * 5 * dir;
							
							var surr_coord:Array[Vector2] = World.V2_Array_Around(extension_center, 4);
							
							var surr_idx:Array[int];
							for c_idx in surr_coord.size():
								surr_idx.append(World.Coord_To_Index(surr_coord[c_idx]));
							
							var waterScore:int = 0;
							for idx in surr_idx:
								
								if t_array[idx] == Terrain.SHALLOWS \
								|| t_array[idx] == Terrain.SEA \
								|| t_array[idx] == Terrain.DEPTHS \
								|| t_array[idx] == Terrain.ABYSS \
								|| t_array[idx] == Terrain.SEA_GREEN:
									waterScore += 1;
								else:
									waterScore -= 1;
							
							print(waterScore);
							
							if waterScore > highest_waterScore && extension_center > Vector2.ZERO:
								highest_waterScore = waterScore;
								dockTarget = extension_center;
								dockIdx = currIdx;
							
							currIdx += 1;
					# END: Look for Suitable Dock Point
					
					# Check for Diagonal
					#if dockIdx == 0 \
					#|| dockIdx == 2 \
					#|| dockIdx == 5 \
					#|| dockIdx == 7:
						#pass;
					
					t_array[World.Coord_To_Index(start)] = Terrain.Null;
					if dockTarget != -Vector2.ONE:
						t_array[World.Coord_To_Index(dockTarget)] = Terrain.TEMPLE_BROWN;
	
	return t_array;
