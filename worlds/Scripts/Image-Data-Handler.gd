extends Node;

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
