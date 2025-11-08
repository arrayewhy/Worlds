extends Node

var _debug:bool;


func Island_CoordArrays_From_TerrainData(terrainData:Array[Map_Data.Terrain], callerPath:String) -> Array[Array]:
	
	if _debug: print_debug("Islands_From_TerrainData, called by: ", callerPath);
	
	var islands:Array[Array] = [];
	
	var checked:Array[Vector2];
	
	var pendingCoords_In:Array[Vector2];
	var pendingCoords_Out:Array[Vector2];
	
	for i in terrainData.size():
		
		var curr_island_coords:Array[Vector2];
		
		if World.Terrain_Is_Land(terrainData[i]) && !checked.has(World.Convert_Index_To_Coord(i)):
			
			pendingCoords_In.append(World.Convert_Index_To_Coord(i));
				
			while pendingCoords_In.size() > 0:
				
				# Loop
				for p in pendingCoords_In:
					
					var surr_coords:Array[Vector2] = World.V2_Array_Around(p, 1, true);
					
					for coord in surr_coords:
					
						var curr_terrain:Map_Data.Terrain = terrainData[World.Convert_Coord_To_Index(coord)];
						
						if World.Terrain_Is_Land(curr_terrain) && !checked.has(coord):
							pendingCoords_Out.append(coord);
					
					curr_island_coords.append(p);
					checked.append(p);
					checked.append_array(surr_coords);
				
				pendingCoords_In = pendingCoords_Out;
				pendingCoords_Out = [];
			
			if curr_island_coords.size() > 0:
				islands.push_back(curr_island_coords);
				curr_island_coords = [];
	
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
				#indices.push_back(World.Convert_Coord_To_Index(coord));
			#islands_in_idx.push_back(indices);
		#
		#return islands_in_idx;


func TerrainClusters_From_Island(type:Map_Data.Terrain, singleIsland:Array[int], terrainData:Array[Map_Data.Terrain]) -> Array[Array]:
	var cluster_array:Array[Array];
	
	var checked:Array[Vector2];
	
	var pendingCoords_In:Array[Vector2];
	var pendingCoords_Out:Array[Vector2];
	
	for idx in singleIsland:
		
		var currCluster:Array[int];
		
		if terrainData[idx] == type && !checked.has(World.Convert_Index_To_Coord(idx)):
			
			pendingCoords_In.append(World.Convert_Index_To_Coord(idx));
				
			while pendingCoords_In.size() > 0:
				
				# Loop
				for p in pendingCoords_In:
					
					var surr_coords:Array[Vector2] = World.V2_Array_Around(p, 1, true);
					
					for coord in surr_coords:
					
						var curr_terrain:Map_Data.Terrain = terrainData[World.Convert_Coord_To_Index(coord)];
						
						if curr_terrain == type && !checked.has(coord):
							pendingCoords_Out.append(coord);
					
					currCluster.append(World.Convert_Coord_To_Index(p));
					checked.append(p);
					checked.append_array(surr_coords);
				
				pendingCoords_In = pendingCoords_Out;
				pendingCoords_Out = [];
			
			if currCluster.size() > 0:
				cluster_array.push_back(currCluster);
				currCluster = [];
	
			continue;
	
	return cluster_array;
