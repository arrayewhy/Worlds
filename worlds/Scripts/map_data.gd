class_name Map_Data

enum Terrain {
	Null, # 0
	#DEBUG
	DEBUG_HOLE,
	# Land
	SKY,
	MOUNTAIN,
	HIGHLAND,
	GROUND,
	COAST,
	TEMPLE_BROWN,
	DOCK,
	# Water
	SHALLOWS, # 5
	SEA,
	DEPTHS,
	ABYSS,
	#SEA_GREEN,
	WATER_COAST,
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


static func Derive_TerrainData_From_NoiseData(peak:float, mountain:float, highland:float, ground:float, coast:float, shallows:float, sea:float, depths:float, noiseData:Array) -> Array[Terrain]:
	
	var t:Array[Terrain];
	
	for d in noiseData:
		if d >= peak:
			t.append(Terrain.SKY);
			continue;
		elif d >= mountain && d < peak:
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
			
			Terrain.SKY: # Now MOUNTAIN
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
			
			Terrain.MOUNTAIN: # Now HILL
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
			
			Terrain.HIGHLAND: # Now GROUND
				if randi_range(0, 1000) > 600:
					m.append(Marking.TREE);
				elif randi_range(0, 1000) > 980:
					m.append(Marking.HOUSE);
				elif randi_range(0, 1000) > 998:
					m.append(Marking.TEMPLE);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.GROUND: # Now SHORE
				if randi_range(0, 1000) > 990:
					m.append(Marking.LIGHTHOUSE);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.SHELL);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.TENT);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.COAST: # Now SHALLOW
				m.append(Marking.Null);
				continue;
				
			Terrain.SHALLOWS: # Now SEA
				if randi_range(0, 1000) > 960:
					m.append(Marking.SMALL_FISH);
				#elif randi_range(0, 1000) > 995:
					#m.append(Marking.JETTY);
				else:
					m.append(Marking.Null);
				continue;
				
			Terrain.SEA: # Now OCEAN
				if randi_range(0, 1000) > 900:
					m.append(Marking.SEAGRASS);
				elif randi_range(0, 1000) > 990:
					m.append(Marking.BIG_FISH);
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
			Terrain.DOCK:
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
			#Marking.SEAGRASS:
				#t[i] = Terrain.SEA_GREEN;
			Marking.TEMPLE:
				t[i] = Terrain.TEMPLE_BROWN;
				
	return t;


static func Amend_MarkingData_Houses(markingData:Array[Marking]) -> Array[Marking]:
	
	var m_array:Array[Marking] = markingData;
	
	#var width:float = World.MapWidth();
	
	for i in m_array.size():
		
		match m_array[i]:
			
			Marking.TREE:
				
				var center:Vector2 = World.Index_To_Coord(i);
				
				var surr_coords:Array[Vector2] = World.V2_Array_Around(center, 1, true);

				#var surr_marks:Array[Marking];
				#
				#for coord in surr_coords:
					#surr_marks.push_back(m_array[World.Coord_To_Index(coord)]);
				#
				#if surr_marks.count(Marking.HOUSE) >= 7:
					#m_array[i] = Marking.HOUSE;
				
				var trees:int = 0;
				
				for coord in surr_coords:
					if m_array[World.Coord_To_Index(coord)] == Marking.TREE:
						trees += 1;

				if trees >= 7:
					m_array[i] = Marking.HOUSE;
				
	return m_array;


static func Amend_TerrainData_Docks(terrainData:Array[Terrain]) -> Array[Terrain]:
	
	#TEMPORARY
	#var done = false;
	
	var t_array:Array[Terrain] = terrainData;
	
	for t_idx in t_array.size():
		
		match t_array[t_idx]:
			
			Terrain.COAST:
			
				if randf_range(0, 1000) < 990:
					continue;
				
				#TEMPORARY
				#if !done:
					#done = true;
					
				var start:Vector2 = World.Index_To_Coord(t_idx);
				
				var dockTarget:Vector2 = -Vector2.ONE;
				var dockIdx:int = 0;
				
				var highest_waterScore:int = 0;
				
				var directions:Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT];
				
				for d in directions:

					var check_center:Vector2i = start + World.CellSize * 5 * d;
					
					var surr_coords:Array[Vector2] = World.V2_Array_Around(check_center, 4);
							
					var surr_indices:Array[int];
					for c_index in surr_coords.size():
						surr_indices.append(World.Coord_To_Index(surr_coords[c_index]));
					
					var score:int = 0;
					for index in surr_indices:
						
						if t_array[index] == Terrain.SHALLOWS \
						|| t_array[index] == Terrain.SEA \
						|| t_array[index] == Terrain.DEPTHS \
						|| t_array[index] == Terrain.ABYSS:
						#|| t_array[index] == Terrain.SEA_GREEN:
							score += 1;
						else:
							score -= 1;
					
					#print(score);
					
					if score > highest_waterScore && check_center > Vector2i.ZERO:
						highest_waterScore = score;
						dockTarget = check_center;
				
				#t_array[World.Coord_To_Index(start)] = Terrain.Null;
				
				if highest_waterScore > 20:

					if dockTarget != -Vector2.ONE:
						
						#t_array[World.Coord_To_Index(dockTarget)] = Terrain.DEBUG_HOLE;
						
						var dist:float = start.distance_to(dockTarget) / World.CellSize;
						
						var dir = (dockTarget - start).normalized() * World.CellSize;
						
						var currCoord:Vector2 = start;
						
						for d in dist:
							
							currCoord += dir;
							
							if t_array[World.Coord_To_Index(currCoord)] == Terrain.DOCK:
								#print("Short Dock");
								break;
							
							t_array[World.Coord_To_Index(currCoord)] = Terrain.DOCK;
						#print("Full Dock");
						#var next:Vector2 = start + dir;
						
						
						
						#while !done:
							#t_array[World.Coord_To_Index(next)] = Terrain.Dock;
							#next += dir;
							#if next == dockTarget:
								#done = true;
					
					#continue;
					
					
					
					#var rows:int = 3;
					#var cols:int = 3;
					#var currIdx:int = 0;
					#
					## START: Look for Suitable Dock Point
					#for row in rows:
						#
						#for col in cols:
							#
							## Determinal Check Direction
							#var dir:Vector2 = Vector2(-1 + col, -1 + row);
					#
							## Skip Center
							#if dir == Vector2.ZERO:
								#continue;
							#
							#var extension_center:Vector2i = start + World.CellSize * 5 * dir;
							#
							#var surr_coord:Array[Vector2] = World.V2_Array_Around(extension_center, 4);
							#
							#var surr_idx:Array[int];
							#for c_idx in surr_coord.size():
								#surr_idx.append(World.Coord_To_Index(surr_coord[c_idx]));
							#
							#var waterScore:int = 0;
							#for idx in surr_idx:
								#
								#if t_array[idx] == Terrain.SHALLOWS \
								#|| t_array[idx] == Terrain.SEA \
								#|| t_array[idx] == Terrain.DEPTHS \
								#|| t_array[idx] == Terrain.ABYSS \
								#|| t_array[idx] == Terrain.SEA_GREEN:
									#waterScore += 1;
								#else:
									#waterScore -= 1;
							#
							#print(waterScore);
							#
							#if waterScore > highest_waterScore && extension_center > Vector2i.ZERO:
								#highest_waterScore = waterScore;
								#dockTarget = extension_center;
								#dockIdx = currIdx;
							#
							#currIdx += 1;
					## END: Look for Suitable Dock Point
					#
					## Check for Diagonal
					##if dockIdx == 0 \
					##|| dockIdx == 2 \
					##|| dockIdx == 5 \
					##|| dockIdx == 7:
						##pass;
					#
					#t_array[World.Coord_To_Index(start)] = Terrain.Null;
					#if dockTarget != -Vector2.ONE:
						#t_array[World.Coord_To_Index(dockTarget)] = Terrain.TEMPLE_BROWN;
	
	return t_array;
