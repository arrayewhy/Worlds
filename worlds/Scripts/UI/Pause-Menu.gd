extends CanvasLayer;

@onready var curtain:ColorRect = $Curtain;

var _paused:bool;

func _ready() -> void:
	HideCurtain();

# Functions ----------------------------------------------------------------------------------------------------

func Toggle_Pause(user:String) -> void:
	_paused = !_paused;
	if _paused:
		ShowCurtain();
		return;
	if !_paused:
		HideCurtain();
	
func Is_Paused() -> bool:
	return _paused;

# Functions ----------------------------------------------------------------------------------------------------

func ShowCurtain() -> void:
	curtain.color.a = 0.5;
	show();
	
func HideCurtain() -> void:
	curtain.color.a = 0;
	hide();
