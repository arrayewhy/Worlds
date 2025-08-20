extends Node


func Islands_From_TerrainData(terrainData:Array[Map_Data.Terrain], convert_to_idx:bool, callerPath:String) -> Array[Array]:
	
	#print_debug("Islands_From_TerrainData, called by: ", callerPath);
	
	var islands:Array[Array] = [];
	
	var checked:Array[Vector2];
	
	var pendingCoords_In:Array[Vector2];
	var pendingCoords_Out:Array[Vector2];
	
	for i in terrainData.size():
		
		var curr_island_chunks:Array[Vector2];
		
		if _Is_Land(terrainData[i]) && !checked.has(World.Index_To_Coord(i)):
			
			var start:Vector2 = World.Index_To_Coord(i);
			
			var surr_coords:Array[Vector2] = World.V2_Array_Around(start, 1, true);
			
			for coord in surr_coords:
				
				var curr_terrain:Map_Data.Terrain = terrainData[World.Coord_To_Index(coord)];
				
				if _Is_Land(curr_terrain) && !checked.has(coord):
					#pendingCoords_In.append(coord);
					pendingCoords_Out.append(coord);
			
			curr_island_chunks.append(start);
			checked.append(start);
			checked.append_array(surr_coords);
			
			pendingCoords_In = pendingCoords_Out;
				
			while pendingCoords_In.size() > 0:
				
				pendingCoords_Out = [];
				
				# Loop
				for p in pendingCoords_In:
					
					surr_coords = World.V2_Array_Around(p, 1, true);
					
					for coord in surr_coords:
					
						var curr_terrain:Map_Data.Terrain = terrainData[World.Coord_To_Index(coord)];
						
						#print("Checked: ", checked);
						#return islands;
						
						if _Is_Land(curr_terrain) && !checked.has(coord):
							#pendingCoords_In.append(coord);
							pendingCoords_Out.append(coord);
					
					curr_island_chunks.append(p);
					checked.append(p);
					checked.append_array(surr_coords);
				
				pendingCoords_In = pendingCoords_Out;
			
			if curr_island_chunks.size() > 0:
				islands.push_back(curr_island_chunks);
				curr_island_chunks = [];
	
			continue;
		
		#print("Skip");
		
	if !convert_to_idx:
		
		return islands;
		
	else:
		
		var islands_in_idx:Array[Array];
		
		for island in islands:
			var indices:Array[int];
			for coord in island:
				indices.push_back(World.Coord_To_Index(coord));
			islands_in_idx.push_back(indices);
		
		return islands_in_idx;


func _Is_Land(terrain:Map_Data.Terrain) -> bool:
	if terrain == Map_Data.Terrain.MOUNTAIN \
	|| terrain == Map_Data.Terrain.HIGHLAND \
	|| terrain == Map_Data.Terrain.GROUND \
	|| terrain == Map_Data.Terrain.COAST \
	|| terrain == Map_Data.Terrain.TEMPLE_BROWN \
	|| terrain == Map_Data.Terrain.DOCK:
		return true;
	return false;
