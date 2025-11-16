extends Node;

var cam:Camera2D;
var initZoom:Vector2;

var currZoomLvl:int = 0;
const zoomLimit:int = 1;

func _ready() -> void:
	cam = get_parent();
	initZoom = cam.zoom;

func Zoom() -> void:
	var worldSize:int = World.Get_WorldSize();
		
	match currZoomLvl:
		worldSize:
			ResetZoom();
			return;
		_:
			if currZoomLvl > zoomLimit:
				ResetZoom();
				return;
			cam.zoom = cam.zoom / 2;
	
	currZoomLvl += 1;

func ResetZoom() -> void:
	cam.zoom = initZoom;
	currZoomLvl = 0;
