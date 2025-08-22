extends Node

var _debug:bool;


func Island_CoordArrays_From_TerrainData(terrainData:Array[Map_Data.Terrain], callerPath:String) -> Array[Array]:
	
	if _debug: print_debug("Islands_From_TerrainData, called by: ", callerPath);
	
	var islands:Array[Array] = [];
	
	var checked:Array[Vector2];
	
	var pendingCoords_In:Array[Vector2];
	var pendingCoords_Out:Array[Vector2];
	
	for i in terrainData.size():
		
		var curr_island_chunks:Array[Vector2];
		
		if World.Terrain_Is_Land(terrainData[i]) && !checked.has(World.Index_To_Coord(i)):
			
			pendingCoords_In.append(World.Index_To_Coord(i));
				
			while pendingCoords_In.size() > 0:
				
				# Loop
				for p in pendingCoords_In:
					
					var surr_coords:Array[Vector2] = World.V2_Array_Around(p, 1, true);
					
					for coord in surr_coords:
					
						var curr_terrain:Map_Data.Terrain = terrainData[World.Coord_To_Index(coord)];
						
						if World.Terrain_Is_Land(curr_terrain) && !checked.has(coord):
							pendingCoords_Out.append(coord);
					
					curr_island_chunks.append(p);
					checked.append(p);
					checked.append_array(surr_coords);
				
				pendingCoords_In = pendingCoords_Out;
				pendingCoords_Out = [];
			
			if curr_island_chunks.size() > 0:
				islands.push_back(curr_island_chunks);
				curr_island_chunks = [];
	
			continue;
	
	return islands;
		
	#if !convert_to_idx:
		#return islands;
	#else:
		#
		#var islands_in_idx:Array[Array];
		#
		#for island in islands:
			#var indices:Array[int];
			#for coord in island:
				#indices.push_back(World.Coord_To_Index(coord));
			#islands_in_idx.push_back(indices);
		#
		#return islands_in_idx;


func TerrainGroups_From_TerrainData(type:Map_Data.Terrain, islandData:Array[Map_Data.Terrain], terrainData:Array[Map_Data.Terrain], convert_to_idx:bool, callerPath:String) -> Array[Array]:
	
	if _debug: print_debug("TerrainGroup_From_TerrainData, called by: ", callerPath);
	
	var total_groups:Array[Array] = [];
	
	var checked:Array[Vector2];
	
	var pendingCoords_In:Array[Vector2];
	var pendingCoords_Out:Array[Vector2];
	
	for i in terrainData.size():
		
		var curr_group_cells:Array[Vector2];
		
		if terrainData[i] == type && !checked.has(World.Index_To_Coord(i)):
			
			pendingCoords_In.append(World.Index_To_Coord(i));
				
			while pendingCoords_In.size() > 0:
				
				# Loopcurr
				for p in pendingCoords_In:
					
					var surr_coords:Array[Vector2] = World.V2_Array_Around(p, 1, true);
					
					for coord in surr_coords:
					
						var curr_terrain:Map_Data.Terrain = terrainData[World.Coord_To_Index(coord)];
						
						if curr_terrain == type && !checked.has(coord):
							pendingCoords_Out.append(coord);
					
					curr_group_cells.append(p);
					checked.append(p);
					checked.append_array(surr_coords);
				
				pendingCoords_In = pendingCoords_Out;
				pendingCoords_Out = [];
			
			if curr_group_cells.size() > 0:
				total_groups.push_back(curr_group_cells);
				curr_group_cells = [];
	
			continue;
		
	if !convert_to_idx:
		return total_groups;
	else:
		
		var total_groups_in_idx:Array[Array];
		
		for group in total_groups:
			var indices:Array[int];
			for coord in group:
				indices.push_back(World.Coord_To_Index(coord));
			total_groups_in_idx.push_back(indices);
		
		return total_groups_in_idx;
