extends Node

@export var images:Array[Image];
@export var biomeHolder:Node;

var _templates:Array[Array]; # Array[Array[Color]]

func _ready() -> void:
	for img in images:
		_templates.push_back(ImageToColArray(img));

func SpawnBiomes_FromImage(indx:int) -> void:
	
	var colArray:Array[Color] = ImageToColArray(images[indx]);
	var currGPos:Vector2i = Vector2i(0, 0);
	
	var offset:Vector2i = (Vector2i(images[indx].get_width(), images[indx].get_height()) - Vector2i(1, 1)) / 2;
	
	for i in colArray.size():
		match colArray[i]:
			
			Color(150, 250, 50, 255): # Grass
				Biome_Master.SpawnBiome(currGPos - offset, Biome_Master.Type.Grass, biomeHolder, \
				Interaction_Master.Type.NULL);
				
			Color(150, 150, 150, 255): # Stone
				Biome_Master.SpawnBiome(currGPos - offset, Biome_Master.Type.Stone, biomeHolder, \
				Interaction_Master.Type.NULL);
			
			Color(0, 0, 0, 255): # DARKNESS
				Biome_Master.SpawnBiome(currGPos - offset, Biome_Master.Type.DARKNESS, biomeHolder, \
				Interaction_Master.Type.NULL);
			
			Color(255, 0, 255, 255): # Random
				Biome_Master.SpawnBiome(currGPos - offset, Biome_Master.RandomBiomeType_Core(), biomeHolder, \
				Interaction_Master.Type.NULL);
			
			Color(255, 250, 50, 255): # Treasure
				pass;
			
			Color(0, 0, 0, 0): # Transparent
				pass;
				
			_:
				printerr(str("Failed to find matching Biome for World Template Colour: ", colArray[i]));
				pass;
				
		if currGPos.x == images[indx].get_width() - 1:
			currGPos.x = 0;
			currGPos.y += 1;
			continue;
		currGPos.x += 1;
		
	#print(colArray.size());

func ImageToColArray(img:Image) -> Array[Color]:
	
	var imgData:PackedByteArray = img.get_data ();
	
	var colArray:Array[Color] = [];
	var rgbaTracker:int;
	var currCol:Color = Color.TRANSPARENT;
	
	for i in imgData.size ():
		
		if rgbaTracker >= 4:
			rgbaTracker = 0;
			colArray.append (currCol);
		
		if rgbaTracker == 0:
			currCol.r = imgData[i];
		if rgbaTracker == 1:
			currCol.g = imgData[i];
		if rgbaTracker == 2:
			currCol.b = imgData[i];
		if rgbaTracker == 3:
			currCol.a = imgData[i];
			
		rgbaTracker += 1;
	
	# Append the Final Pixel
	colArray.append (currCol);
	
	return colArray;
