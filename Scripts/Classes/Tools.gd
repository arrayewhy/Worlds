class_name Tools


# Get ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

static func Float_OnGrid(val:float) -> float:
	return floor(val / World.CellSize) * World.CellSize;

static func Coord_OnGrid(v2:Vector2) -> Vector2:
	return round(v2 / World.CellSize) * World.CellSize;

static func V2_Array_Around(pos:Vector2, radius:int, skipCenter:bool = false) -> Array[Vector2]:
	
	var p:Array[Vector2] = [];
	
	var length:float = radius * 2 + 1;
	
	var start:Vector2 = pos + (-Vector2.ONE * radius * World.CellSize);
	
	#REFACTOR
	for y in length:
		
		if start.y + y * World.CellSize < 0 || start.y + y * World.CellSize >= World.MAP_UNIT_WIDTH * World.CellSize:
			continue;
		
		for x in length:
			
			if start.x + x * World.CellSize < 0 || start.x + x * World.CellSize >= World.MAP_UNIT_WIDTH * World.CellSize:
				continue;
			p.append(start + Vector2(x, y) * World.CellSize);
	
	if skipCenter && p.has(pos):
		p.erase(pos);
	
	return p;


# Conversion ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


static func Convert_Index_To_Coord(idx:int) -> Vector2:
	return Vector2(idx % World.MAP_UNIT_WIDTH, idx / World.MAP_UNIT_WIDTH) * World.CellSize;

static func Convert_Coord_To_Index(coord:Vector2) -> int:
	#var float_idx:float = (World.MAP_UNIT_WIDTH * coord.y + coord.x) / CellSize;
	#return int(float_idx);
	return (World.MAP_UNIT_WIDTH * coord.y + coord.x) / World.CellSize;

static func Convert_CoordArray_To_IdxArray(coordArray:Array[Vector2]) -> Array[int]:
	var idx_array:Array[int];
	for coord in coordArray:
		var idx:int = int((World.MAP_UNIT_WIDTH * coord.y + coord.x) / World.CellSize);
		idx_array.push_back(idx);
	return idx_array;


# Terrain ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


static func Terrain_Is_Land(terrain:Map_Data.Terrain) -> bool:
	if terrain == Map_Data.Terrain.MOUNTAIN \
	#|| terrain == Map_Data.Terrain.MOUNTAIN_PATH \
	|| terrain == Map_Data.Terrain.FOREST \
	|| terrain == Map_Data.Terrain.GROUND \
	|| terrain == Map_Data.Terrain.SHORE \
	|| terrain == Map_Data.Terrain.TEMPLE_BROWN:
	#|| terrain == Map_Data.Terrain.DOCK:
		return true;
	return false;


# Data ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

static func Colours_From_Tex2D(img:Texture2D, has_alpha:bool) -> Array[Array]:
	
	var img_data:PackedByteArray = img.get_image().get_data();
	
	var colours:Array[Array];
	
	var curr_col:Array[int];
	
	var curr_channel:int = 0;

	for i in img_data.size():
		
		if curr_channel < 3:
			
			# Add this to the Current Colour to form a Color
			# => [255, 255, 255, 255] => [R, G, B, A]
			
			curr_col.append(img_data[i]); # RGB
			
			# For Images with NO Alpha
			
			if !has_alpha && curr_channel == 2:
				
				curr_col.append(255);
				# Record this color then Empty it
				colours.append(curr_col);
				curr_col = [];
				# Prepare for the Next Colour
				curr_channel = 0;
				
				continue;
			
			curr_channel += 1;

		else:
			
			# For Images with Alpha
			
			curr_col.append(img_data[i]); # A
			# Record this color then Empty it
			colours.append(curr_col);
			curr_col = [];
			# Prepare for the Next Colour
			curr_channel = 0;
	
	return colours;
